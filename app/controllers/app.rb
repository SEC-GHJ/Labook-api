# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers'

module Labook
  # Web controller for Labook API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    plugin :request_headers
    include SecureRequestHelpers

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth_account = authenticated_account(routing.headers)
      rescue AuthToken::InvalidTokenError
        Api.logger.error('Invalid auth token')
        routing.halt 403, { message: 'Invalid auth token' }.to_json
        @auth_account = nil
      rescue StandardError => e
        Api.logger.error(e.message)
        routing.halt 500
      end

      routing.root do
        response.status = 200
        # Api.logger.debug 'Testing LabookAPI at /api/v1'
        # Api.logger.info 'Testing LabookAPI at /api/v1'
        # Api.logger.warn 'Testing LabookAPI at /api/v1'
        # Api.logger.error 'Testing LabookAPI at /api/v1'
        { message: 'LabookAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'

      routing.on @api_root do
        routing.multi_route
      end
    end
  end
end
