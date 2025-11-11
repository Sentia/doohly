# frozen_string_literal: true

RSpec.describe Doohly::Client do
  let(:api_token) { "test_api_token_123" }
  let(:client) { described_class.new(api_token: api_token) }

  describe "#initialize" do
    context "with valid api_token" do
      it "creates a new client instance" do
        expect(client).to be_a(described_class)
        expect(client.api_token).to eq(api_token)
      end
    end

    context "without api_token" do
      it "raises ConfigurationError" do
        expect { described_class.new }.to raise_error(Doohly::ConfigurationError)
      end
    end

    context "with empty api_token" do
      it "raises ConfigurationError" do
        expect { described_class.new(api_token: "") }.to raise_error(Doohly::ConfigurationError)
      end
    end
  end

  describe "#devices" do
    it "fetches list of devices" do
      stub_request(:get, "https://api.dooh.ly/api/public/v1/devices")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(
          status: 200,
          body: { devices: [{ id: "device-1", name: "Test Device" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.devices
      expect(response["devices"]).to be_an(Array)
      expect(response["devices"].first["id"]).to eq("device-1")
    end
  end

  describe "#device" do
    let(:device_id) { "device-123" }

    it "fetches a specific device" do
      stub_request(:get, "https://api.dooh.ly/api/public/v2/devices/#{device_id}")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(
          status: 200,
          body: { id: device_id, name: "Test Device" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.device(device_id)
      expect(response["id"]).to eq(device_id)
    end

    it "raises NotFoundError when device does not exist" do
      stub_request(:get, "https://api.dooh.ly/api/public/v2/devices/#{device_id}")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(status: 404, body: "Not found")

      expect { client.device(device_id) }.to raise_error(Doohly::NotFoundError)
    end
  end

  describe "#bookings" do
    it "fetches list of bookings without filter" do
      stub_request(:get, "https://api.dooh.ly/api/public/v2/bookings")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(
          status: 200,
          body: { bookings: [] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.bookings
      expect(response["bookings"]).to be_an(Array)
    end

    it "fetches list of bookings with status filter" do
      stub_request(:get, "https://api.dooh.ly/api/public/v2/bookings?status=booked")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(
          status: 200,
          body: { bookings: [{ id: "booking-1", status: "booked" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.bookings(status: "booked")
      expect(response["bookings"]).to be_an(Array)
    end
  end

  describe "#create_booking" do
    let(:booking_params) do
      {
        name: "Test Booking",
        status: "draft",
        external_id: "ext-123"
      }
    end

    it "creates a new booking" do
      stub_request(:post, "https://api.dooh.ly/api/public/v2/bookings")
        .to_return(
          status: 201,
          body: { id: "booking-123", name: "Test Booking" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.create_booking(**booking_params)
      expect(response["id"]).to eq("booking-123")
    end
  end

  describe "#update_booking" do
    let(:booking_id) { "booking-123" }

    it "updates an existing booking" do
      stub_request(:patch, "https://api.dooh.ly/api/public/v2/bookings/#{booking_id}")
        .with(
          headers: { "Authorization" => "Bearer #{api_token}", "Content-Type" => "application/json" },
          body: { name: "Updated Booking" }.to_json
        )
        .to_return(
          status: 200,
          body: { id: booking_id, name: "Updated Booking" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.update_booking(booking_id, name: "Updated Booking")
      expect(response["name"]).to eq("Updated Booking")
    end
  end

  describe "#delete_booking" do
    let(:booking_id) { "booking-123" }

    it "deletes a booking" do
      stub_request(:delete, "https://api.dooh.ly/api/public/v2/bookings/#{booking_id}")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(
          status: 200,
          body: { removedFromDeviceCount: 2 }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.delete_booking(booking_id)
      expect(response["removedFromDeviceCount"]).to eq(2)
    end
  end

  describe "#get_signed_upload_url" do
    it "gets a signed upload URL for creative" do
      stub_request(:post, "https://api.dooh.ly/api/public/v1/library/creatives/upload")
        .with(
          headers: { "Authorization" => "Bearer #{api_token}", "Content-Type" => "application/json" },
          body: {
            name: "test.png",
            mimeType: "image/png",
            fileSize: 123_456
          }.to_json
        )
        .to_return(
          status: 200,
          body: { id: "upload-123", uploadUrl: "https://storage.example.com/upload" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.get_signed_upload_url(
        name: "test.png",
        mime_type: "image/png",
        file_size: 123_456
      )
      expect(response["id"]).to eq("upload-123")
      expect(response["uploadUrl"]).to include("https://")
    end
  end

  describe "#creative_upload_status" do
    let(:upload_id) { "upload-123" }

    it "gets upload status" do
      stub_request(:get, "https://api.dooh.ly/api/public/v1/library/creatives/upload/#{upload_id}")
        .with(headers: { "Authorization" => "Bearer #{api_token}" })
        .to_return(
          status: 200,
          body: { creative: { id: "creative-123", status: "complete" } }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.creative_upload_status(upload_id)
      expect(response["creative"]["status"]).to eq("complete")
    end
  end

  describe "error handling" do
    it "raises AuthenticationError on 401" do
      stub_request(:get, "https://api.dooh.ly/api/public/v1/devices")
        .to_return(status: 401, body: "Unauthorized")

      expect { client.devices }.to raise_error(Doohly::AuthenticationError)
    end

    it "raises RateLimitError on 429" do
      stub_request(:get, "https://api.dooh.ly/api/public/v1/devices")
        .to_return(status: 429, body: "Rate limit exceeded")

      expect { client.devices }.to raise_error(Doohly::RateLimitError)
    end

    it "raises ServerError on 500" do
      stub_request(:get, "https://api.dooh.ly/api/public/v1/devices")
        .to_return(status: 500, body: "Internal Server Error")

      expect { client.devices }.to raise_error(Doohly::ServerError)
    end
  end
end
