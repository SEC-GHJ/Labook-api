# frozen_string_literal: true

module Labook
  # Find account and check password
  class AuthenticateAccount
    # Error for invalid credentials
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        super
        @credentials = msg
      end

      def message
        "Invalid Credentials for: #{@credentials[:username]}"
      end
    end

    def self.call(credentials)
      account = Account.first(account: credentials[:account])
      raise UnauthorizedError, credentials if account.nil?
      raise UnauthorizedError, credentials unless account.password?(credentials[:password])

      account_and_token(account)
    end

    def self.account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
