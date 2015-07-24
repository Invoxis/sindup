module Sindup
  module Collection

    def self.of(klass)
      klass_name = klass.name.split('::').last
      (self.const_get klass_name rescue self.const_set klass_name, Class.new(Base))
    end

    class Base

      attr_reader   :origin # what created the instance

      def initialize(options = {})
        raise "Class #{sels.class.name} is not supposed to be instantiated" if self.instance_of? Base
        @item_class = options[:class] # the class of the item collected
        @origin = options[:origin]
        @markers = []
        @criterias = []
        @end_criteria = nil
      end

      def initialize_clone(other)
        super(other)
        @markers = @markers.dup
        @criterias = @criterias.dup
        @end_criteria = @end_criteria.dup unless @end_criteria.nil?
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

            self.define_singleton_method("until") do |last_id|
              cur_end_crit = @end_criteria.dup
              @end_criteria = last_id.to_i
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
                items = items.take_while { |item| item.id > @end_criteria } unless @end_criteria.nil?
              end while items.size == batch_size
              @markers.pop

              # iterating on matching results
              loop do
                # picking matching items
                items = items.select { |item| @criterias.all? { |crit| crit.call(item) } }
                counter_matching_initialized_items += items.size
                # executing block
                (self << items.reverse).each { |item| blk.call(item) }
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
              item = if opts[:item].nil?
                @item_class.from_hash(@connection.create(opts), self.default_objects_options)
              else
                @item_class.from_hash(@connection.create(opts[:item].attributes), self.default_objects_options)
              end
              (self << item).first
            end

          when :find
            self.define_singleton_method("find") do |options = {}, &blk|
              item = @item_class.from_hash(@connection.find(options))
              self << item
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
        (self << @item_class.from_hash(options, &block)).first
      end

      def known(options = {}, &block)
        item = self.new options, &block
        self << item
      end

      protected

      def default_objects_options
        { origin: self, parent: @origin }
      end

      # Adopt items, giving them a copy of the connection
      #
      # @param [Array[Sindup::Collection::Base]] items
      # @return [Array[Sindup::Collection::Base], Sindup::Collection::Base] items, or just item
      def <<(*items)
        items.flatten!
        items.each do |item|
          raise ArgumentError, "Received #{item.class.name}, expecting #{@item_class.class.name}" unless item.is_a? @item_class
          raise ArgumentError, "Object already in a collection" if item.instance_variable_defined?("@connection")

          conn = item.instance_variable_set "@connection", @connection.dup

          routes = @connection.define_routes.select { |k, _| item.routes_actions.include? k }
          conn.define_routes(routes)

          item.initialize_routes_keys
          item.initialize_collections
          item.initialize_queries
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
