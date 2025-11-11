# frozen_string_literal: true

module Doohly
  # Configuration management for Doohly client
  class Configuration
    attr_accessor :api_token, :api_base_url, :timeout, :open_timeout, :logger

    DEFAULT_API_BASE_URL = "https://api.dooh.ly/api/public"
    DEFAULT_TIMEOUT = 30
    DEFAULT_OPEN_TIMEOUT = 10

    def initialize
      @api_token = nil
      @api_base_url = DEFAULT_API_BASE_URL
      @timeout = DEFAULT_TIMEOUT
      @open_timeout = DEFAULT_OPEN_TIMEOUT
      @logger = nil
    end

    def validate!
      raise ConfigurationError, "API token is required" if api_token.nil? || api_token.empty?

      true
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration.validate!
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
