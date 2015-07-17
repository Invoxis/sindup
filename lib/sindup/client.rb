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
      @connection = Internal::Connection.new options.merge({ parent: self })
      initialize_collections
    end

    def authorize_url(params = {})
      @connection.authorize_url params
    end

    def current_token
      @connection.current_token
    end

    def waiting_authorization_callback?
      @connection.waiting_authorization_callback?
    end

    # @param [Hash] options
    #  @option [String] :mode (optional)
    #  @option [String] :requester
    #  @option [Strind] :code
    def self.received_authorization_callback(opts = {})
      options = { mode: (opts["mode"] || 'auto'), requester: opts["requester"], code: opts["code"] }
      ap options
      puts "#{__callee__} begin"
      raise ArgumentError if options.values.any?(&:nil?) || (not %{auto manual}.include? options[:mode])

      o = ObjectSpace._id2ref(options[:requester].to_i)# rescue nil)
      ap o
      raise "No matching requester found" if o.nil? || (not o.is_a? self) || (not o.waiting_authorization_callback?)

      o.echo_authorization_callback options[:code]
      puts "#{__callee__} end"
      nil
    end

    private

    def initialize_collections
      collection_of Folder do |connection|
        connection.define_routes(
          index:  "/folders",
          show:   "/folders/%{folder_id}",
          edit:   "/folders/%{folder_id}",
          create: "/folders",
          delete: "/folders/%{folder_id}"
        )
      end
    end

  end # !Client
end # !Sindup
