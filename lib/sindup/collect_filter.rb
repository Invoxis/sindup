module Sindup
  class CollectFilter < Internal::Base

    attr_reader :collect_filter_id
    attr_accessor :name, :query, :language

    def initialize(options = {}, &block)
      super(options)
      @collect_filter_id = options["collect_filter_id"] || options[:collect_filter_id]
      @name = (options["filter"]["name"] rescue nil) || options[:name]
      @query = (options["filter"]["criteria"].first["value"] rescue nil) || options[:query]
      yield self if block_given?
    end

    def initialize_routes_keys
      super(collect_filter_id: collect_filter_id)
    end

    def self.from_hash(h, o = {})
      super (h.has_key?("data") ? h["data"] : h), o
    end

    def inspect
      [
        "#<#{self.class.name}:#{self.object_id}",
        "@collect_filter_id=#{@collect_filter_id.inspect}",
        "@name=#{@name.inspect}",
        "@query=#{@query.inspect}",
        "@language=#{@language.inspect}",
        "@connection(#{@connection.nil? ? 'no' : 'yes'})>",
      ].join(", ")
    end

    private

    def primary_key() :collect_filter_id end

  end # !CollectFilter
end # !Sindup
