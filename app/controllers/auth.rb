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
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end

      routing.is 'register' do
        # POST /api/v1/auth/register
        routing.post do
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(reg_data).call

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
        line_code = JsonRequestBody.parse_symbolize(routing.body.read)[:code]
        line_account = AuthorizeLineSso.new(line_code).call

        response.status = 200
        { data: line_account }.to_json
      rescue AuthorizeLineSso::UserNotFound => e
        puts [e.class, e.message].join ': '
        routing.halt '404', { message: e.message, user_info: e.user_info }.to_json
      rescue StandardError => error
        puts "FAILED to validate Line account: #{error.inspect}"
        puts error.backtrace
        routing.halt 500
      end

      # POST api/v1/auth/line_notify_sso
      routing.is 'line_notify_sso' do
        line_notify_code = JsonRequestBody.parse_symbolize(routing.body.read)[:code]
        account = AuthorizeLineNotifySso.new(line_notify_code, @auth_account).call

        response.status = 200
        { data: account }.to_json
      rescue StandardError => error
        puts "FAILED to validate Line account: #{error.inspect}"
        puts error.backtrace
        routing.halt 400 
      end
    end
  end
end
