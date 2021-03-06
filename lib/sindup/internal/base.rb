module Sindup::Internal
  class Base

    attr_reader :routes_actions, :origin, :parent

    def initialize(options = {}, &block)
      raise "Class #{self.class.name} is not supposed to be instantiated" if self.instance_of? Base
      @origin = options[:origin]
      @parent = options[:parent]
      @routes_actions = [:edit, :delete]
    end

    def initialize_collections() end

    def initialize_routes_keys(k = {})
      @connection.define_routes_keys k
    end

    def initialize_queries
      raise if @connection.nil?
      @connection.define_routes.keys.each do |qkw|
        case qkw

        when :self
          self.define_singleton_method("show") do |*p, &b|
            self.class.from_hash @connection.self(*p, &b)
          end

        when :delete
          self.define_singleton_method("delete") do |*p, &b|
            self.class.from_hash @connection.delete(*p, &b)
          end

        when :edit
          self.define_singleton_method("save") do |*p, &b|
            if self.send(primary_key).nil?
              raise "Not linked to any collection, can't create object." if @origin.nil?
              @origin.create(item: self)
            else self.class.from_hash @connection.edit(attributes)
            end.first
          end

        end # !case
      end # !each
    end

    def self.from_hash(r, opts = {})
      if r.is_a? Array
        r.map { |o| self.new o.merge opts }
      elsif r == true || r == false
        return r
      else
        self.new r.merge opts
      end
    end

    def attributes
      keys = self.instance_variables.map(&:to_s).map { |v| v.gsub('@', '') }.map(&:to_sym) - [:origin, :connection, :parent, :routes_actions]
      keys.each_with_object({}) { |a, mem| mem[a] = send(a) }
    end

    private

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
        coll = Sindup::Collection::of(klass).new(:klass => klass, origin: self)
        conn = @connection.dup

        yield conn if block_given?

        coll.instance_variable_set('@connection', conn)
        coll.initialize_queries
        self.define_singleton_method(coll_name) { coll.clone }
      end

      self.send(coll_name)
    end

    def class_to_string_container(c)
      c.name.split('::')[1..-1].join.gsub(/([^\^])([A-Z])/, '\1_\2').downcase + 's'
    end

  end # !Base
end # !Sindup
