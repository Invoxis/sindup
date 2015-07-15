require 'faraday'

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
      @routes = {}
      @routes_keys = {}
      # options for self
      @app_url = options[:url][:app]
      @api_url = options[:url][:api]
      options.delete :url
      # options for Faraday
      requests = options[:request].is_a?(Array) ? options[:request] : [options[:request]].compact
      b = Proc.new do |builder|
        builder.adapter options[:adapter] unless options[:adapter].nil?
        requests.each { |r| builder.request r }
      end
      options.delete :adapter
      options.delete :request
      user = options.delete :user
      password = options.delete :password
      token_auth = options.delete :token_auth
      @faraday = Faraday.new(options, &b)
      @faraday.basic_auth(user, password) unless user.nil? or password.nil?
      @faraday.token_auth(token_auth) unless token_auth.nil?
      yield self if block_given?
    end

    def initialize_dup(other)
      @routes = {}
    end

    def define_routes(routes = {})
      # retrieving new valid routes
      new_routes = routes.select { |r, _| @@authorized_requests.include? r }
      @routes = @routes.merge new_routes
      # creating/overwritting routes using new ones
      new_routes.keys.each { |action| define_route_method(action) }
      @routes.dup # safe return
    end

    def define_routes_keys(keys = {})
      @routes_keys = @routes_keys.merge keys
      @routes_keys.dup # safe return
    end

    private

    def define_route_method(action)
      method = self.send("#{action.to_s}?")
      self.define_singleton_method(action) do |params = {}, header = nil|
        route = @routes[action] % @routes_keys
        @faraday.send(method, @api_url + route, params, header)
      end
    end

    def index?()  :get    end
    def create?() :post   end
    def show?()   :get    end
    def edit?()   :put    end
    def delete?() :delete end

  end # !Connection
end # !Sindup::Internal
