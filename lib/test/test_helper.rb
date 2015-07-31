# require 'sindup'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures"
  c.hook_into :webmock
end

def get_client(t = get_token)
  Sindup.new(
    app_id: "myAppId",
    app_secret: "myAppSecret",
    client_id: 1337,
    auth: { token: t }
  )
end

def get_token
  Sindup::Authorization::Token.new("myToken", "myRefreshToken", Time.now)
end
