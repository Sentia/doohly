# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "doohly"
require "webmock/rspec"
require "vcr"

# VCR configuration
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<API_TOKEN>") { ENV.fetch("DOOHLY_API_TOKEN", "test_token") }
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method uri body]
  }
  # Allow WebMock stubs when no cassette is in use
  config.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset configuration before each test
  config.before do
    Doohly.reset_configuration!
  end
end
