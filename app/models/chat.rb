# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class Chat < Sequel::Model
    many_to_one :accounts_account, class: :'Labook::AccountsAccount',
                                   key: %i[sender_id receiver_id]

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :content
    plugin :uuid, field: :sender_id
    plugin :uuid, field: :receiver_id

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
          type: 'chat',
          attributes: {
            chat_id:,
            sender_id:,
            content:,
            created_at:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
