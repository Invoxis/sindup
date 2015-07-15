module Sindup

  class << self

    # Alias for Sindup::Client.new
    def new(options = {}, &block)
      default_options = {
        url: {
          app: "https://app.sindup.com",
          api: "https://restapi.sindup.net"
        },
      }
      options = default_options.merge options
      Client.new options, &block
    end

  end

end # !Sindup

# Debug
require 'ap'

# Internal
require './lib/sindup/internal/base'
require './lib/sindup/internal/connection'

# Components
require './lib/sindup/collection'
require './lib/sindup/client'

# Models
require './lib/sindup/folder'
require './lib/sindup/collect_filter'
# require './lib/sindup/result'
