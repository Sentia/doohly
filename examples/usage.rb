#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "doohly"

# Configure with your API token
api_token = ENV.fetch("DOOHLY_API_TOKEN", "your_api_token_here")

# Option 1: Global configuration
Doohly.configure do |config|
  config.api_token = api_token
  config.timeout = 30
end

client = Doohly::Client.new

# Option 2: Direct client initialization
# client = Doohly::Client.new(api_token: api_token)

puts "=" * 80
puts "Doohly Ruby Client - Usage Examples"
puts "=" * 80

# List devices
puts "\n📱 Fetching devices..."
begin
  devices = client.devices
  device_count = devices.is_a?(Array) ? devices.count : 0
  puts "Found #{device_count} devices"
  if devices.is_a?(Array) && devices.any?
    first_device = devices.first
    puts "  First device: #{first_device["name"]} (#{first_device["id"]})"
  end
rescue Doohly::APIError => e
  puts "Error fetching devices: #{e.message}"
end

# List bookings
puts "\n📅 Fetching bookings..."
begin
  bookings = client.bookings
  booking_list = bookings.is_a?(Hash) ? bookings["bookings"] : bookings
  booking_count = booking_list.is_a?(Array) ? booking_list.count : 0
  puts "Found #{booking_count} bookings"
  if booking_list.is_a?(Array) && booking_list.any?
    first_booking = booking_list.first
    puts "  First booking: #{first_booking["name"]} (#{first_booking["status"]})"
  end
rescue Doohly::APIError => e
  puts "Error fetching bookings: #{e.message}"
end

# Get signed upload URL
puts "\n🎨 Getting signed upload URL for creative..."
begin
  upload_info = client.get_signed_upload_url(
    name: "example-creative.png",
    mime_type: "image/png",
    file_size: 100_000,
    playback_scaling: "contain"
  )
  puts "Upload ID: #{upload_info["id"]}"
  puts "Upload URL: #{upload_info["uploadUrl"][0..50]}..."
rescue Doohly::APIError => e
  puts "Error getting upload URL: #{e.message}"
end

puts "\n✅ Example completed!"
