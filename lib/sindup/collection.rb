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
      end

      def define_routes_keys(keys = {})
        @connection.define_routes_keys keys
      end

      def new(options = {}, &block)
        options = options.merge(
          origin: self,
          parent: @origin
        )
        @item_class.new options, &block
      end

      def known(options = {}, &block)
        item = self.new options, &block
        conn = item.instance_variable_set "@connection", @connection.dup

        routes = @connection.define_routes.select { |k, _| item.routes_actions.include? k }
        conn.define_routes(routes)

        item.initialize_collections
        item
      end

      def create(options = {}, &block)
        item = @connection.create name: "hello world"
        ap item
        puts item.inspect
        # self.known item.attributes
      end

    end # !Base

  end # !Collection
end # !Sindup
