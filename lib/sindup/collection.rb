module Sindup
  module Collection

    def self.of(klass)
      klass_name = klass.name.split('::').last
      (self.const_get(klass_name, false) rescue self.const_set klass_name, Class.new(Base))
    end

    class Base

      attr_reader   :origin # what created the instance

      def initialize(options = {})
        raise "Class #{sels.class.name} is not supposed to be instantiated" if self.instance_of? Base
        @item_class = options[:klass] # the class of the item collected
        @origin = options[:origin]
        @markers = []
        @criterias = []
        @end_criteria = nil
      end

      def initialize_clone(other)
        super(other)
        @markers = @markers.dup
        @criterias = @criterias.dup
      end

      def initialize_queries
        @connection.define_routes.each do |qkw, r|
          case qkw
          when :index

            self.define_singleton_method("where") do |*crits|
              cur_crits = @criterias.dup
              @criterias += crits
              new_coll = self.clone
              @criterias = cur_crits
              new_coll
            end

            self.define_singleton_method("until") do |crit|
              cur_end_crit = @end_criteria
              @end_criteria = crit
              new_coll = self.clone
              @end_criteria = cur_end_crit
              new_coll
            end

            self.define_singleton_method("each") do |options = {}, &blk|
              raise if blk.nil?
              batch_size = options[:batch_size] || 100
              counter_initialized_items = counter_different_initialized_items = counter_matching_initialized_items = 0
              counter_markers, counter_queries = -1, 0

              # querying until limit
              begin
                cursor ||= nil
                @markers << Marker.new(cursor)
                counter_markers += 1
                # querying
                result = @connection.index(cursor: cursor, count: batch_size)
                items = @item_class.from_hash result
                cursor = (result["cursor"]["next"] rescue nil)
                counter_queries += 1

                counter_initialized_items += items.size
                counter_different_initialized_items += items.size
                unless @end_criteria.nil?
                  items = if @end_criteria.is_a? Integer
                    items = items.take_while { |item| item.send(item.primary_key) != @end_criteria }
                  else items.take_while { |item| @end_criteria.call(item) }
                  end
                end
              end while items.size == batch_size
              @markers.pop

              # iterating on matching results
              loop do
                # picking matching items
                items = items.select { |item| @criterias.all? { |crit| crit.call(item) } }
                counter_matching_initialized_items += items.size
                # executing block
                (self.adopt items.reverse).each { |item| blk.call(item) }
                # preparing next round
                break if (m = @markers.pop).nil?
                items = @item_class.from_hash @connection.index(cursor: m.cursor, count: batch_size)
                counter_initialized_items += items.size
                counter_queries += 1
              end

              {
                cursor: (items.first.id rescue nil),
                total_queries: counter_queries,
                total_markers: counter_markers,
                total_initialized_items: counter_initialized_items,
                total_different_initialized_items: counter_different_initialized_items,
                total_matching_initialized_items: counter_matching_initialized_items
              }
            end

          when :create
            self.define_singleton_method("create") do |opts = {}, &blk|
              item = opts[:item] || self.new(opts)
              yield item unless blk.nil?
              item.remove_instance_variable("@connection")
              item = @item_class.from_hash(@connection.create(item.attributes), self.default_objects_options)
              (self.adopt item).first
            end

          when :find
            self.define_singleton_method("find") do |options = {}, &blk|
              item = @item_class.from_hash(@connection.find(options))
              self.adopt item
              blk.call(item) unless blk.nil?
              item
            end

          end # !case
        end # !each
      end

      def define_routes_keys(keys = {})
        @connection.define_routes_keys keys
        self.initialize_queries
      end

      def new(options = {}, &block)
        options = options.merge(self.default_objects_options)
        item = @item_class.from_hash(options, &block)
        (self.adopt item, i_c: !!item.send(item.primary_key)).first
      end

      def inspect
        "#<#{self.class.name}:#{self.object_id}>"
      end

      protected

      def default_objects_options
        { origin: self, parent: @origin }
      end

      # Adopt items, giving them a copy of the connection
      #
      # @param [Array[Sindup::Collection::Base]] items
      # @return [Array[Sindup::Collection::Base], Sindup::Collection::Base] items, or just item
      def adopt(*items, i_rk: true, i_c: true, i_q: true)
        items.flatten!
        items.each do |item|
          raise ArgumentError, "Received #{item.class.name}, expecting #{@item_class.class.name}" unless item.is_a? @item_class
          raise ArgumentError, "Object already in a collection" if item.instance_variable_defined?("@connection")

          conn = item.instance_variable_set "@connection", @connection.dup

          routes = @connection.define_routes.select { |k, _| item.routes_actions.include? k }
          conn.define_routes(routes)

          item.initialize_routes_keys if i_rk
          item.initialize_collections if i_c
          item.initialize_queries if i_q
        end
        items
      end

      private

      class Marker

        attr_reader   :cursor

        def initialize(cursor)
          @cursor = cursor
        end
      end

    end # !Base

  end # !Collection
end # !Sindup
