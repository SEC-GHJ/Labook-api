# frozen_string_literal: true

require 'roda'
require 'json'

module Labook
  # Web controller for Labook API
  class Api < Roda
    plugin :halt
    plugin :multi_route

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end
    
    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) || 
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)


      routing.root do
        response.status = 200
        Api.logger.debug 'Testing LabookAPI at /api/v1'
        Api.logger.info 'Testing LabookAPI at /api/v1'
        Api.logger.warn 'Testing LabookAPI at /api/v1'
        Api.logger.error 'Testing LabookAPI at /api/v1'
        { message: 'LabookAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'

      routing.on @api_root do
        routing.multi_route
      end
    end
  end
end
