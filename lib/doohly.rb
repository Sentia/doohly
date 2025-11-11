# frozen_string_literal: true

require_relative "doohly/version"
require_relative "doohly/error"
require_relative "doohly/configuration"
require_relative "doohly/client"

# Main module for Doohly Ruby client
module Doohly
  class << self
    # Quick client initialization
    # @param api_token [String] Doohly API token
    # @return [Doohly::Client] Configured client instance
    def client(api_token: nil)
      Client.new(api_token: api_token)
    end
  end
end
