# frozen_string_literal: true

require 'uri'
require 'net/http'

module Labook
  # find or create an  Sso Account based on Line
  class AuthorizeLineSso
    def initialize(code)
      @code = code
    end

    def call
      line_account = get_access_token_from_line
      sso_account = find_or_create_line_sso_account(line_account)

      account_and_token(sso_account)
    end

    def request_data
      data = {
        'grant_type': 'authorization_code',
        'code': @code,
        'redirect_uri': Api.config.LINE_REDIRECT_URI,
        'client_id': Api.config.LINE_CLIENT_ID,
        'client_secret': Api.config.LINE_CLIENT_SECRET
      }
      data = URI.encode_www_form(data)
    end

    def get_access_token_from_line
      uri = URI(Api.config.LINE_OAUTH_TOKEN_URL)
      header = { 'Content-Type': 'application/x-www-form-urlencoded' }
      
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      response = https.post(uri, request_data, header)
      raise unless response.is_a?(Net::HTTPSuccess)

      line_account = LineAccount.new(JSON.parse(response.body))
      {
        username: line_account.sub,
        email: line_account.email,
        line_access_token: line_account.access_token
      }
    end

    def find_or_create_line_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_line_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'line_sso_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
