module Sindup
  class Folder < Internal::Base

    attr_reader :id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parent

    # id: nil, name: nil, description: nil, parent: nil
    def initialize(options = {}, &block)
      super(options)
      puts "initializing a new #{self.class.name}"
      @id = options[:id]
      self.name = options[:name]
      self.description = options[:description]
      yield self if block_given?
    end

    def initialize_collections
      collection_of CollectFilter, name: 'news' do |connection|
        connection.define_routes(
          index:  "/folders/%{folder_id}/collectfilters%{cf_type}",
          create: "/folders/%{folder_id}/collectfilters%{cf_type}",
          delete: "/folders/%{folder_id}/collectfilters%{cf_type}/%{cf_id}"
        )
        connection.define_routes_keys(folder_id: @id, cf_type: "news")
      end
    end

  end # !Folder
end # !Sindup
