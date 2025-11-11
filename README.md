# Doohly Ruby Client

[![Gem Version](https://badge.fury.io/rb/doohly.svg)](https://badge.fury.io/rb/doohly)
[![CI](https://github.com/Sentia/doohly/workflows/CI/badge.svg)](https://github.com/Sentia/doohly/actions)
[![codecov](https://codecov.io/gh/Sentia/doohly-ruby/branch/main/graph/badge.svg)](https://codecov.io/gh/Sentia/doohly-ruby)

A Ruby client library for the [Doohly](https://dooh.ly) Digital Out-of-Home (DOOH) advertising platform API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'doohly'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install doohly
```

## Usage

### Configuration

Configure the gem globally:

```ruby
require 'doohly'

Doohly.configure do |config|
  config.api_token = ENV['DOOHLY_API_TOKEN']
  config.timeout = 30
  config.open_timeout = 10
  # config.logger = Logger.new(STDOUT) # Optional: Enable request logging
end
```

Or create a client instance directly:

```ruby
client = Doohly::Client.new(api_token: 'your_api_token')
```

### Devices

```ruby
# List all devices
devices = client.devices
puts devices

# Get a specific device
device = client.device('device-id-123')
puts device['name']
puts device['isConnected']
```

### Bookings

```ruby
# List all bookings
bookings = client.bookings

# Filter bookings by status
active_bookings = client.bookings(status: 'booked')

# Get a specific booking
booking = client.booking('booking-id-123')

# Create a new booking
new_booking = client.create_booking(
  name: 'My Campaign',
  status: 'draft',
  external_id: 'campaign-001',
  plays_per_loop: 2,
  loops_per_play: 1,
  play_consecutively: true,
  purchase_type: 'Sold',
  schedule: {
    startDate: '2024-01-01',
    endDate: '2024-12-31',
    startTime: '09:00:00',
    endTime: '18:00:00',
    days: ['mon', 'tue', 'wed', 'thu', 'fri'],
    timezone: 'America/New_York',
    useLocalTime: false
  },
  assigned_creatives: [
    {
      creative: { id: 'creative-id-123' },
      durationSource: 'custom',
      durationMs: 15000,
      order: 1
    }
  ],
  assigned_frames: [
    { frame: { id: 'frame-id-456' } }
  ],
  seedooh: {
    enabled: false
  }
)

# Update a booking
updated_booking = client.update_booking(
  'booking-id-123',
  name: 'Updated Campaign Name',
  status: 'booked'
)

# Delete a booking
result = client.delete_booking('booking-id-123')
puts "Removed from #{result['removedFromDeviceCount']} devices"
```

### Creatives

```ruby
# Get signed URL for uploading a creative
upload_info = client.get_signed_upload_url(
  name: 'my-video.mp4',
  mime_type: 'video/mp4',
  file_size: 5_242_880, # 5MB in bytes
  playback_scaling: 'contain',
  path: ['campaigns', '2024']
)

upload_url = upload_info['uploadUrl']
upload_id = upload_info['id']

# Upload the file to the signed URL (using your preferred HTTP client)
require 'net/http'
uri = URI(upload_url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Put.new(uri)
request['Content-Type'] = 'video/mp4'
request.body = File.read('path/to/my-video.mp4')
response = http.request(request)

# Check upload status
status = client.creative_upload_status(upload_id)
puts status['creative']['status'] # 'pending', 'processing', or 'complete'
```

## Error Handling

The gem provides specific error classes for different scenarios:

```ruby
begin
  client.device('non-existent-id')
rescue Doohly::NotFoundError => e
  puts "Device not found: #{e.message}"
  puts "Status: #{e.status}"
rescue Doohly::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Doohly::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
rescue Doohly::APIError => e
  puts "API error: #{e.message}"
end
```

Available error classes:
- `Doohly::Error` - Base error class
- `Doohly::ConfigurationError` - Invalid configuration
- `Doohly::APIError` - Base API error
- `Doohly::AuthenticationError` - 401 errors
- `Doohly::NotFoundError` - 404 errors
- `Doohly::BadRequestError` - 400 errors
- `Doohly::RateLimitError` - 429 errors
- `Doohly::ServerError` - 5xx errors

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

```bash
bundle exec rspec
```

### Linting

```bash
bundle exec rubocop
```

### Code Coverage

Code coverage reports are generated automatically when running tests. Open `coverage/index.html` to view the report.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sentia/doohly. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Doohly project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Sentia/doohly/blob/main/CODE_OF_CONDUCT.md).
