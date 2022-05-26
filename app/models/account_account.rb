# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class AccountsAccount < Sequel::Model
    one_to_many :chats, class: :'Labook::Chat',
                        key: %i[sender_id receiver_id]

    plugin :association_dependencies,
           chats: :destroy

    def newest_chat_message
      chats.sort_by(&:created_at).reverse[0]
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'chatroom',
          attributes: {
            sender_id:,
            receiver_id:
          },
          include: {
            newest_chat_message:,
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
