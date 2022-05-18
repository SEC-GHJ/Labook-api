# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('auth') do |routing|
      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end

      routing.is 'register' do
        # POST /api/v1/auth/register
        routing.post do
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          puts "reg: #{reg_data}"
          VerifyRegistration.new(reg_data).call

          response.status = 202
          { message: 'Verification email sent'}.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, {message: e.message }.to_json
        rescue VerifyRegistration::EmailProviderError
          routing.halt 500, { message: 'Error sending email' }.to_json
        rescue StandardError => e
          Api.logger.error "Could not verify registration: #{e.inspect}"
          routing.halt 500
        end
      end
    end
  end
end
