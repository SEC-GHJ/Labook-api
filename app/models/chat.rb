# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class Chat < Sequel::Model
    # many_to_one :account, class: :'Labook::Account', key: :sender_id
    # many_to_one :account, class: :'Labook::Account', key: :receiver_id

    one_to_one :accounts_accounts

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :content

    def content
      SecureDB.decrypt content_secure
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'post',
            attributes: {
              chat_id:,
              sender_id:,
              receiver_id:,
              content:
            }
          },
          include: {
            account:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end