# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('auth') do |routing|
      # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          auth_account = AuthenticateAccount.call(@request_data)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          Api.logger.error [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end

      routing.is 'register' do
        # POST /api/v1/auth/register
        routing.post do
          VerifyRegistration.new(@request_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue VerifyRegistration::EmailProviderError
          routing.halt 500, { message: 'Error sending email' }.to_json
        rescue StandardError => e
          Api.logger.error "Could not verify registration: #{e.inspect}"
          routing.halt 500
        end
      end

      # POST api/v1/auth/line_sso
      routing.is 'line_sso' do
        line_account = AuthorizeLineSso.new(@request_data[:code]).call

        response.status = 200
        { data: line_account }.to_json
      rescue AuthorizeLineSso::UserNotFound => e
        puts [e.class, e.message].join ': '
        routing.halt '404', { message: e.message, user_info: e.user_info }.to_json
      rescue StandardError => e
        puts "FAILED to validate Line account: #{e.inspect}"
        puts e.backtrace
        routing.halt 500
      end

      # POST api/v1/auth/line_notify_sso
      routing.is 'line_notify_sso' do
        account = AuthorizeLineNotifySso.new(@request_data[:code], @auth_account).call

        response.status = 200
        { data: account }.to_json
      rescue StandardError => e
        puts "FAILED to validate Line account: #{e.inspect}"
        puts e.backtrace
        routing.halt 400
      end
    end
  end
end
