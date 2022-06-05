# frozen_string_literal: true

require 'jwt'

module Labook
  # Maps Line account details to attributes
  class LineAccount
    def initialize(line_account)
      @line_account = line_account
    end

    def access_token
      @line_account['access_token']
    end

    def token_type
      @line_account['token_type']
    end

    def refresh_token
      @line_account['refresh_token']
    end

    def expires_in
      @line_account['expires_in']
    end

    def id_token
      # get user info which is encoded by json web tokens
      JWT.decode(@line_account['id_token'], nil, false)
    end

    def user_info
      id_token[0]
    end

    def email
      user_info['email']
    end

    def name
      user_info['name']
    end

    def sub
      user_info['sub']
    end
  end
end
