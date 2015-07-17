module Sindup::Internal
  class Connection

    @@authorized_requests =  [:index, :show, :edit, :create, :delete]

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
      ap options # DEBUG

      puts "#{__callee__} begin" # DEBUG
      @client = options[:parent]
      @routes = {}
      @routes_keys = {}

      # client credentials
      client_id, app_id, app_secret = nil
      if options.has_key?(:app_id) && options.has_key?(:app_secret)
        client_id = options.delete :client_id
        app_id = options.delete :app_id
        app_secret = options.delete :app_secret
      else raise ArgumentError, "Missing client credentials"
      end

      # app url
      api_url, app_url = nil
      if options.has_key?(:url) && options[:url].has_key?(:app_url) && options[:url].has_key?(:api_url)
        app_url = options[:url][:app_url]
        api_url = options[:url][:api_url]
        options.delete :url
      else raise ArgumentError, "Missing app url"
      end

      @oa_client = ::OAuth2::Client.new app_id, app_secret, site: app_url
      @client_id = client_id
      @api_url = api_url

      # authorization url
      # TODO redirect_url optional?
      authorize_url, token_url, redirect_url = nil
      if options.has_key?(:authorize_url)
        authorize_url = options[:authorize_url][:authorize_url]
        token_url = options[:authorize_url][:token_url]
        redirect_url = options[:authorize_url][:redirect_url]
        options.delete :authorize_url
      end

      # connection informations
      if options.has_key?(:auth) && options[:auth].has_key?(:basic) # String as "email:password"
        puts "#{__callee__} begin if" # DEBUG
        account, password = options[:auth].delete(:basic).split(':')
        fill_form = options[:auth].delete(:fill_login_form_proc)

        raise ArgumentError, "Missing redirect url" if redirect_url.nil?
        raise ArgumentError, "Missing proc filling form" if fill_form.nil?

        @token_request = {
          delay: 20,
          redirect_url: redirect_url +
            (redirect_url.include?("?") ? "&" : "?") +
            URI.encode_www_form(requester: @client.object_id, mode: "auto")
        }
        form_uri = @oa_client.auth_code.authorize_url(redirect_uri: @token_request[:redirect_url])

        puts "#{__callee__} begin loop" # DEBUG
        fill_form.call(form_uri, account, password)
        @token_request[:delay] -= sleep(1) while @token_request[:code].nil? && (not @token_request[:delay].zero?) 
        raise "Request timed out" if @token_request[:code].nil? # TODO clean exception
        puts "#{__callee__} end loop" # DEBUG

        @token = @oa_client.auth_code.get_token(@token_request[:code], redirect_uri: @token_request[:redirect_url])
        @token_request = nil

        puts "#{__callee__} end if" # DEBUG
      elsif options.has_key?(:auth) && options[:auth].has_key?(:token) # Sindup::Authorization::Token
        t = options[:auth].delete(:token)
        @token = ::OAuth2::AccessToken.new @oa_client, t.token, refresh_token: t.refresh_token, expires_at: t.expires_at.to_i

      elsif options.has_key?(:auth) && options[:auth][:manual]
        # TODO
        # allow the user to make everything manualy

      else raise ArgumentError, "Missing auth"
      end

      yield self if block_given?
      puts "#{__callee__} end" # DEBUG
      self
    end

    def initialize_dup
      @routes = {}
    end

    # routing

    def define_routes(routes = {})
      # retrieving new valid routes
      new_routes = routes.select { |r, _| @@authorized_requests.include? r }
      @routes = @routes.merge new_routes
      # creating/overriding routes using new ones
      new_routes.keys.each { |action| define_route_method(action) }
      @routes.dup
    end

    def define_routes_keys(keys = {})
      @routes_keys = @routes_keys.merge keys
      @routes_keys.dup
    end

    # getters

    def current_token
      ::Sindup::Authorization::Token.from_hash @token.to_hash
    end

    def authorize_url(options)
      @oa_client.auth_code.authorize_url(options)
    end

    # authorization callbacks

    def waiting_authorization_callback?
      !@token_request.nil? && @token_request[:code].nil?
    end

    def echo_authorization_callback(code)
      puts "#{__callee__} begin"
      raise unless waiting_authorization_callback?
      @token_request[:code] = code
      puts "#{__callee__} end"
    end
      
    private

    def define_route_method(action)
      # method = self.send("#{action.to_s}?")
      # self.define_singleton_method(action) do |params = {}, header = nil|
      #   route = @routes[action] % @routes_keys
      #   @faraday.send(method, @api_url + route, params, header)
      # end
    end

    # def index?()  :get    end
    # def create?() :post   end
    # def show?()   :get    end
    # def edit?()   :put    end
    # def delete?() :delete end

  end # !Connection
end # !Sindup::Internal
