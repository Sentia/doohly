# frozen_string_literal: true

module Doohly
  # Base error class for all Doohly errors
  class Error < StandardError; end

  # Raised when API request fails
  class APIError < Error
    attr_reader :status, :body, :response

    def initialize(message, status: nil, body: nil, response: nil)
      @status = status
      @body = body
      @response = response
      super(message)
    end
  end

  # Raised when configuration is invalid
  class ConfigurationError < Error; end

  # Raised when authentication fails
  class AuthenticationError < APIError; end

  # Raised when resource is not found
  class NotFoundError < APIError; end

  # Raised when request is invalid
  class BadRequestError < APIError; end

  # Raised when rate limit is exceeded
  class RateLimitError < APIError; end

  # Raised when server error occurs
  class ServerError < APIError; end
end
