module Sindup::Authorization
  class Token

    attr_reader :token, :refresh_token, :expires_at

    # @param [String] token
    # @param [String] refresh_token
    # @param [Time] expires_at
    def initialize(token, refresh_token, expires_at)
      raise ArgumentError unless token.is_a?(String) && refresh_token.is_a?(String) && expires_at.is_a?(Time)
      @token = token
      @refresh_token = refresh_token
      @expires_at = expires_at
    end

    # Create a token from a hash
    #
    # @param [Hash] options
    #  @option [String]  :token
    #  @option [String]  :refresh_token
    #  @option [Integer] :expires_at
    # @return [Sindup::Authorization::Token]
    def self.from_hash(options = {})
      self.new(options[:access_token], options[:refresh_token], Time.at(options[:expires_at]))
    end

  end
end
