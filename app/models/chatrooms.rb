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
      @chatrooms.sort_by!{ |room| room[:include].created_at }.reverse!
    end

    def find_last_contact(other_account_id:)
      messageA = AccountsAccount.first(
                  sender_id: @owner.account_id,
                  receiver_id: other_account_id
                 )
      messageB = AccountsAccount.first(
                  sender_id: other_account_id,
                  receiver_id: @owner.account_id
                 )
      
      return nil if messageA.nil? && messageB.nil?
      return messageA.newest_chat_message if messageB.nil?
      return messageB.newest_chat_message if messageA.nil?

      messageA = messageA.newest_chat_message
      messageB = messageB.newest_chat_message

      # prevent from exit AccountsAccount but no chats
      return messageA if messageB.nil?
      return messageB if messageA.nil?

      # return the newest time (bigger)
      (messageA.created_at > messageB.created_at) ? messageA : messageB
    end

    def to_h
      @chatrooms
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
