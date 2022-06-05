# frozen_string_literal: true

require 'uri'
require 'net/http'

module Labook
  # connect an Line Notify Sso with Account
  class AuthorizeLineNotifySso
    def initialize(code, auth_account)
      @code = code
      @auth_account = auth_account
    end

    def call
      line_notify_info = get_access_token_from_line
      updated_account = account_add_line_notify(line_notify_info)

      account_and_token(updated_account)
    end

    def request_data
      data = {
        'grant_type': 'authorization_code',
        'code': @code,
        'redirect_uri': Api.config.LINE_NOTIFY_REDIRECT_URI,
        'client_id': Api.config.LINE_NOTIFY_CLIENT_ID,
        'client_secret': Api.config.LINE_NOTIFY_CLIENT_SECRET
      }
      data = URI.encode_www_form(data)
    end

    def get_access_token_from_line
      uri = URI(Api.config.LINE_NOTIFY_OAUTH_TOKEN_URL)
      header = { 'Content-Type': 'application/x-www-form-urlencoded' }
      
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      response = https.post(uri, request_data, header)
      raise unless response.is_a?(Net::HTTPSuccess)

      body = JSON.parse(response.body)
      {
        username: @auth_account['username'],
        access_token: body['access_token']
      }
    end

    def account_add_line_notify(account_data)
      Account.first(username: account_data[:username])
             .update(line_notify_access_token: account_data[:access_token])
    end

    def account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account: 
        }
      }
    end
  end
end
