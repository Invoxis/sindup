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

            self.define_singleton_method("each") do |options = {}, &blk|
              raise if blk.nil?
              batch_size = options[:batch_size] || 100

              # querying while respecting criterias
              begin
                cursor ||= nil
                @markers << Marker.new(cursor) unless cursor.nil?
                result = @connection.index(cursor: cursor, size: batch_size)
                items = @item_class.from_hash result
                cursor = result["cursor"]
                # should have stop criterias & select criterias
                # while condition then should be checked before select criterias
                items = items.take_while { |item| @criterias.all? { |crit| crit.call(item) } }
              end while items.size == batch_size

              # iterating on results
              loop do
                (self << items.reverse).each { |item| blk.call(item) }
                break if (m = @markers.pop).nil?
                items = @item_class.from_hash @connection.index(cursor: m.cursor, size: batch_size)
              end

            end

          when :create
            self.define_singleton_method("create") do |item = nil, opts = {}, &blk|
              item = @item_class.from_hash(@connection.create(options), self.default_objects_options) if item.nil?
              self << item
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
        @item_class.from_hash options, &block
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
          item.define_singleton_method(:conn) { @connection } # DEBUG
          conn.define_singleton_method(:tok) { @token } # DEBUG
        end
        items.size <= 1 ? items.first : items
      end

      private

      class Marker < ::OpenStruct

        attr_reader   :cursor

        def initialize(cursor, options = {}, &block)
          @cursor = cursor
          super(options)
          yield self if block_given?
        end
      end

    end # !Base

  end # !Collection
end # !Sindup
