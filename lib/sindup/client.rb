module Sindup
  class Client < Internal::Base

    # @param options [Hash]
    #  @option url [Hash]
    #   @option app [String]
    #   @option api [String]
    #  @option user [String]
    #  @option password [String]
    #  @option token_auth [String]
    #  @option adapter [Symbole]
    #  @option request [Array[Symbole]]
    #  @option ssl [Hash]
    #   @option ca_path [String]
    #  @option proxy [Hash|String]
    def initialize(options = {}, &block)
      @connection = Internal::Connection.new options
      initialize_collections
    end

    def authorize_url(params = {})
      @connection.authorize_url params
    end

    def current_token
      @connection.current_token
    end

    def self.received_authorization_callback(opts = {})
      opts.select { |k, v| %{mode code error}.include? k }.to_json
    end

    private

    def initialize_collections
      collection_of Folder do |connection|
        connection.define_routes(
          index:  "/folders",
          edit:   "/folders/%{folder_id}",
          create: "/folders",
          delete: "/folders/%{folder_id}"
        )
      end
    end

  end # !Client
end # !Sindup
