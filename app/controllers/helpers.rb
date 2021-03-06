# frozen_string_literal: true

module Labook
  # Methods for controllers to mixin
  module SecureRequestHelpers
    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authenticated_account(headers)
      return nil unless headers['AUTHORIZATION']

      scheme, auth_token = headers['AUTHORIZATION'].split
      account_payload = AuthToken.new(auth_token).payload
      scheme.match?(/^Bearer$/i) ? account_payload['attributes'] : nil
    end
  end
end
