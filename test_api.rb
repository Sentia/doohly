#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "doohly"

api_token = ENV.fetch("DOOHLY_API_TOKEN")

client = Doohly::Client.new(api_token: api_token)

puts "Testing API connection..."
puts

begin
  devices = client.devices
  puts "✅ API connection successful!"
  puts "Response type: #{devices.class}"
  puts "Response: #{devices.inspect}"
rescue Doohly::AuthenticationError => e
  puts "❌ Authentication failed: #{e.message}"
rescue Doohly::APIError => e
  puts "❌ API error: #{e.message} (Status: #{e.status})"
rescue StandardError => e
  puts "❌ Error: #{e.class} - #{e.message}"
  puts e.backtrace.first(5)
end
