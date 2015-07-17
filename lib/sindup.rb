module Sindup

  class << self

    # Alias for Sindup::Client.new
    def new(options = {}, &block)
      fill_login_form = ->(url, email, password) do
        agent = Mechanize.new { |a| a.verify_mode = OpenSSL::SSL::VERIFY_NONE }
        page_login = agent.get(url)
        form_login = page_login.forms.first
        field_email = form_login.field_with(id: 'email')
        field_password = form_login.field_with(id: 'password')
        button_accept = form_login.button_with(id: 'authorized')
        field_email.value = email
        field_password.value = password
        form_login.submit button_accept
        nil
      end # !lambda

      default_options = {
        url: {
          app_url: "https://app.sindup.com",
          api_url: "https://restapi.sindup.net"
        },
        auth: {
          fill_login_form_proc: fill_login_form
        }
      }
      options = default_options.merge(options) { |k, x, y| x.merge y }
      Client.new options, &block
    end

    def method_missing(meth, *args, &blk)
      Sindup::Client.send(meth, *args, &blk)
    end

  end

end # !Sindup

# Debug
require 'ap'

# Internal
require 'sindup/internal/base'
require 'sindup/internal/connection'
require 'sindup/authorization/token'

# Components
require 'sindup/collection'
require 'sindup/client'

# Models
require 'sindup/folder'
require 'sindup/collect_filter'
# require './lib/sindup/result'

# Requirements
require 'mechanize'
require 'oauth2'