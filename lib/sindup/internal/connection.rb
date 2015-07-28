module Sindup::Internal
  class Connection

    @@authorized_requests =  [:index, :find, :self, :edit, :create, :delete]

    def initialize(options = {}, &block)
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

      @oa_client = ::OAuth2::Client.new app_id, app_secret, site: app_url, raise_errors: false
      @client_id = client_id
      @api_url = api_url

      # authorization url
      authorize_url, token_url, redirect_url = nil
      if options.has_key?(:authorize_url)
        authorize_url = options[:authorize_url][:authorize_url]
        token_url = options[:authorize_url][:token_url]
        redirect_url = options[:authorize_url][:redirect_url]
        options.delete :authorize_url
      end

      # connection informations
      if options.has_key?(:auth) && options[:auth].has_key?(:basic) # String as "email:password"
        account, password = options[:auth].delete(:basic).split(':')
        fill_form = options[:auth].delete(:fill_login_form_proc)

        raise ArgumentError, "Missing redirect url" if redirect_url.nil?
        raise ArgumentError, "Missing proc filling form" if fill_form.nil?

        form_uri = @oa_client.auth_code.authorize_url(redirect_uri: redirect_url)
        redirect_res = JSON.parse fill_form.call(form_uri, account, password)
        raise redirect_res["error"] if redirect_res.has_key?("error")

        @token = @oa_client.auth_code.get_token(redirect_res["code"], redirect_uri: redirect_url)

      elsif options.has_key?(:auth) && options[:auth].has_key?(:token) # Sindup::Authorization::Token
        t = options[:auth].delete(:token)
        @token = ::OAuth2::AccessToken.new @oa_client, t.token, refresh_token: t.refresh_token, expires_at: t.expires_at.to_i

      elsif options.has_key?(:auth) && options[:auth][:manual]
        # TODO
        # allow the user to make everything manualy

      else raise ArgumentError, "Missing auth"
      end

      yield self if block_given?
      self
    end

    def initialize_dup(other)
      super other
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

    private

    def refresh_token!
      @token = @token.refresh!
      raise @token.params["error_description"] if @token.params.has_key?("error")
    end

    def define_route_method(action)
      request = query_keyword_to_request_type(action)
      self.define_singleton_method(action) do |params = {}, header = nil|
        begin
          refresh_token! if @token.expired?
          route = @api_url + (@routes[action] % @routes_keys.merge(params))
          result = @token.send(*request.call(route, params.select { |_,v| !v.nil? }, header))
          raise result.error unless result.error.nil?
          JSON.parse result.body
        rescue => e
          raise Sindup::Error, e.message
        end
      end # !proc
    end

    def query_keyword_to_request_type(qkw)
      case qkw
      when :create      then  ->(r, p, h) { return :post,   r,   body: p, headers: h }
      when :edit        then  ->(r, p, h) { return :put,    r,   body: p, headers: h }
      when :index       then  ->(r, p, h) { return :get,    r, params: p, headers: h }
      when :find, :self then  ->(r, p, h) { return :get,    r, params: p, headers: h }
      when :delete      then  ->(r, p, h) { return :delete, r, params: p, headers: h }
      else raise ArgumentError, "Unknown query"
      end
    end

  end # !Connection
end # !Sindup::Internal
