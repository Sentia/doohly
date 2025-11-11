# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "json"

module Doohly
  # Main API client for Doohly
  class Client
    attr_reader :api_token, :api_base_url

    def initialize(api_token: nil, api_base_url: nil)
      @api_token = api_token || Doohly.configuration.api_token
      @api_base_url = api_base_url || Doohly.configuration.api_base_url

      raise ConfigurationError, "API token is required" if @api_token.nil? || @api_token.empty?

      @connection = build_connection
    end

    # Bookings API

    # GET /v2/bookings
    # @param status [String, nil] Filter by status (e.g., 'booked', 'paused', 'completed')
    # @return [Hash] List of bookings
    def bookings(status: nil)
      params = {}
      params[:status] = status if status
      get("v2/bookings", params)
    end

    # GET /v2/bookings/:id
    # @param id [String] Booking ID
    # @return [Hash] Booking details
    def booking(id)
      get("v2/bookings/#{id}")
    end

    # POST /v2/bookings - Create a new booking
    # @param name [String] Booking name
    # @param external_id [String, nil] External reference ID
    # @param plays_per_loop [Integer, nil] Number of plays per loop
    # @param loops_per_play [Integer, nil] Number of loops per play
    # @param play_consecutively [Boolean, nil] Whether to play consecutively
    # @param purchase_type [String, nil] Purchase type (e.g., 'Sold', 'Bonus')
    # @param campaign [Hash, nil] Campaign details
    # @param schedule [Hash, nil] Schedule configuration
    # @param assigned_creatives [Array<Hash>, nil] Array of creative assignments
    # @param assigned_frames [Array<Hash>, nil] Array of frame assignments
    # @param tags [Array<String>, nil] Tags for the booking
    # @param seedooh [Hash, nil] SeeDooh configuration
    # @param status [String, nil] Booking status
    # @return [Hash] Created booking details
    def create_booking(name:, external_id: nil, plays_per_loop: nil, loops_per_play: nil,
                       play_consecutively: nil, purchase_type: nil, campaign: nil,
                       schedule: nil, assigned_creatives: nil, assigned_frames: nil,
                       tags: nil, seedooh: nil, status: nil)
      body = { name: name }
      body[:externalId] = external_id if external_id
      body[:playsPerLoop] = plays_per_loop if plays_per_loop
      body[:loopsPerPlay] = loops_per_play if loops_per_play
      body[:playConsecutively] = play_consecutively unless play_consecutively.nil?
      body[:purchaseType] = purchase_type if purchase_type
      body[:campaign] = campaign if campaign
      body[:schedule] = schedule if schedule
      body[:assignedCreatives] = assigned_creatives if assigned_creatives
      body[:assignedFrames] = assigned_frames if assigned_frames
      body[:tags] = tags if tags
      body[:seedooh] = seedooh if seedooh
      body[:status] = status if status

      post("v2/bookings", body)
    end

    # PATCH /v2/bookings/:id - Update an existing booking
    # @param id [String] Booking ID
    # @param name [String, nil] Booking name
    # @param external_id [String, nil] External reference ID
    # @param plays_per_loop [Integer, nil] Number of plays per loop
    # @param loops_per_play [Integer, nil] Number of loops per play
    # @param play_consecutively [Boolean, nil] Whether to play consecutively
    # @param purchase_type [String, nil] Purchase type
    # @param campaign [Hash, nil] Campaign details
    # @param schedule [Hash, nil] Schedule configuration
    # @param assigned_creatives [Array<Hash>, nil] Array of creative assignments
    # @param assigned_frames [Array<Hash>, nil] Array of frame assignments
    # @param tags [Array<String>, nil] Tags for the booking
    # @param seedooh [Hash, nil] SeeDooh configuration
    # @param status [String, nil] Booking status
    # @return [Hash] Updated booking details
    def update_booking(id, name: nil, external_id: nil, plays_per_loop: nil, loops_per_play: nil,
                       play_consecutively: nil, purchase_type: nil, campaign: nil,
                       schedule: nil, assigned_creatives: nil, assigned_frames: nil,
                       tags: nil, seedooh: nil, status: nil)
      body = {}
      body[:name] = name if name
      body[:externalId] = external_id unless external_id.nil?
      body[:playsPerLoop] = plays_per_loop if plays_per_loop
      body[:loopsPerPlay] = loops_per_play if loops_per_play
      body[:playConsecutively] = play_consecutively unless play_consecutively.nil?
      body[:purchaseType] = purchase_type if purchase_type
      body[:campaign] = campaign unless campaign.nil?
      body[:schedule] = schedule if schedule
      body[:assignedCreatives] = assigned_creatives if assigned_creatives
      body[:assignedFrames] = assigned_frames if assigned_frames
      body[:tags] = tags if tags
      body[:seedooh] = seedooh if seedooh
      body[:status] = status if status

      patch("v2/bookings/#{id}", body)
    end

    # DELETE /v2/bookings/:id - Delete an existing booking
    # @param id [String] Booking ID
    # @return [Hash] Deletion result
    def delete_booking(id)
      delete("v2/bookings/#{id}")
    end

    # Devices API

    # GET /v1/devices
    # @return [Hash] List of devices
    def devices
      get("v1/devices")
    end

    # GET /v2/devices/:id
    # @param id [String] Device ID
    # @return [Hash] Device details
    def device(id)
      get("v2/devices/#{id}")
    end

    # Creatives API

    # GET /v1/library/creatives/upload/:id - Get creative upload status
    # @param id [String] Upload ID
    # @return [Hash] Upload status
    def creative_upload_status(id)
      get("v1/library/creatives/upload/#{id}")
    end

    # POST /v1/library/creatives/upload - Get signed upload URL
    # @param name [String] Creative name
    # @param mime_type [String] MIME type (e.g., 'image/png', 'video/mp4')
    # @param file_size [Integer] File size in bytes
    # @param playback_scaling [String, nil] Playback scaling mode (e.g., 'contain', 'cover')
    # @param path [Array<String>, nil] Folder path for organization
    # @return [Hash] Upload information including signed URL
    def get_signed_upload_url(name:, mime_type:, file_size:, playback_scaling: nil, path: nil)
      body = {
        name: name,
        mimeType: mime_type,
        fileSize: file_size
      }
      body[:playbackScaling] = playback_scaling if playback_scaling
      body[:path] = path if path

      post("v1/library/creatives/upload", body)
    end

    private

    def build_connection
      Faraday.new(url: @api_base_url) do |conn|
        conn.request :authorization, "Bearer", @api_token
        conn.request :json
        conn.response :json, content_type: /json$/
        conn.response :logger, Doohly.configuration.logger if Doohly.configuration.logger
        conn.options.timeout = Doohly.configuration.timeout
        conn.options.open_timeout = Doohly.configuration.open_timeout
        conn.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      response = @connection.get(path, params)
      handle_response(response)
    end

    def post(path, body)
      response = @connection.post(path) do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = body.to_json
      end
      handle_response(response)
    end

    def patch(path, body)
      response = @connection.patch(path) do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = body.to_json
      end
      handle_response(response)
    end

    def delete(path)
      response = @connection.delete(path)
      handle_response(response)
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 400
        raise BadRequestError.new(
          "Bad Request: #{response.body}",
          status: response.status,
          body: response.body,
          response: response
        )
      when 401
        raise AuthenticationError.new(
          "Authentication failed: #{response.body}",
          status: response.status,
          body: response.body,
          response: response
        )
      when 404
        raise NotFoundError.new(
          "Resource not found: #{response.body}",
          status: response.status,
          body: response.body,
          response: response
        )
      when 429
        raise RateLimitError.new(
          "Rate limit exceeded: #{response.body}",
          status: response.status,
          body: response.body,
          response: response
        )
      when 500..599
        raise ServerError.new(
          "Server error: #{response.body}",
          status: response.status,
          body: response.body,
          response: response
        )
      else
        raise APIError.new(
          "API Error: #{response.status} - #{response.body}",
          status: response.status,
          body: response.body,
          response: response
        )
      end
    end
  end
end
