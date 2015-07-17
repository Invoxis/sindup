module Sindup::Internal
  class Base

    attr_reader :routes_actions, :origin, :parent

    def initialize(options = {}, &block)
      raise "Class #{self.class.name} is not supposed to be instantiated" if self.instance_of? Base
      @origin = options[:origin]
      @parent = options[:parent]
      @routes_actions = define_routes_actions.map(&:to_sym)
    end

    def initialize_collections; end

    private

    def define_routes_actions
      return :show, :edit, :delete
    end

    # Define programmatically a collection and make it readable
    # throw instance method
    #
    # @param klass [Class]
    # @param options [Hash]
    #  @option :name [String] (optionnal) the name to give to the collection
    #
    # @note implementation choices :
    #  1. instance_variable_set(n, coll); define_singleton_method(n) { instance_variable_get n }
    #  2. define_singleton_method(n) { coll }
    #  At the moment, the second choice is used. I'm afraid of the behavior of Ruby's GC.
    #  I know what to do in case of segmentation fault...
    def collection_of(klass, options = {}, &block)
      coll_name = options[:name] || class_to_string_container(klass)

      unless self.respond_to?(coll_name)
        coll = Sindup::Collection::of(klass).new(:class => klass, origin: self)
        conn = @connection.dup
        yield conn if block_given?

        coll.instance_variable_set('@connection', conn)
        self.define_singleton_method(coll_name) { coll.dup }
      end

      self.send(coll_name)
    end

    def class_to_string_container(c)
      c.name.split('::')[1..-1].join.gsub(/([^\^])([A-Z])/, '\1_\2').downcase + 's'
    end

  end # !Base
end # !Sindup
