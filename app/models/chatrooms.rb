# frozen_string_literal: true

module Labook
  # Deal with the chatroom format
  class Chatrooms
    def initialize(owner)
      @owner = owner
      @others = @owner.mailed_accounts.uniq
      # append the last seen message info
      @chatrooms = @others.map do |other_account|
        last_message = find_last_contact(other_account_id: other_account.account_id)

        other_account.to_h.merge!(include: last_message, type: 'chatroom')
      end

      # sort by newest message

      @chatrooms.sort_by! do |room| 
        if room[:include].nil?
          Time.now
        else
          room[:include]&.created_at 
        end
      
      end.reverse!
    end

    def find_last_contact(other_account_id:)
      chatroom_a = AccountsAccount.first(
        sender_id: @owner.account_id,
        receiver_id: other_account_id
      )
      chatroom_b = AccountsAccount.first(
        sender_id: other_account_id,
        receiver_id: @owner.account_id
      )

      return nil if chatroom_a.nil? && chatroom_b.nil?
      return chatroom_a.newest_chat_message if chatroom_b.nil?
      return chatroom_b.newest_chat_message if chatroom_a.nil?

      message_a = chatroom_a.newest_chat_message
      message_b = chatroom_b.newest_chat_message

      # prevent from exit AccountsAccount but no chats
      return message_a || message_b if message_b.nil? || message_a.nil?

      # return the newest time (bigger)
      [message_a, message_b].max_by(&:created_at)
    end

    def to_h
      @chatrooms
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
