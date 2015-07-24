module Sindup
  class Folder < Internal::Base

    attr_reader :folder_id
    attr_accessor :name
    attr_accessor :description

    # id: nil, name: nil, description: nil, parent: nil
    def initialize(options = {}, &block)
      super(options)
      @folder_id = options["folder_id"] || options[:folder_id]
      self.name = options["name"] || options[:name]
      self.description = options["description"] || options[:description]
      yield self if block_given?
    end

    def initialize_collections
      collection_of CollectFilter, name: 'news' do |connection|
        connection.define_routes(
          index:  "/folders/%{folder_id}/collectfilters%{cf_type}",
          create: "/folders/%{folder_id}/collectfilters%{cf_type}",
          delete: "/folders/%{folder_id}/collectfilters%{cf_type}/%{cf_id}"
        )
        connection.define_routes_keys(folder_id: folder_id, cf_type: "news")
      end
    end

    def initialize_routes_keys
      super(folder_id: folder_id)
    end

    def self.from_hash(h, o = {})
      super (h.has_key?("data") ? h["data"] : h), o
    end

    def inspect
      [
        "#<#{self.class.name}:#{self.object_id}",
        "@folder_id=#{@folder_id.inspect}", "@name=#{@name.inspect}", "@description=#{@description.inspect}",
        "@connection(#{@connection.nil? ? 'no' : 'yes'})>",
      ].join(", ")
    end

  end # !Folder
end # !Sindup
