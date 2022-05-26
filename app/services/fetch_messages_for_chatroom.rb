# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchMessagesForChatroom
    class NoMessageError < StandardError
      message = "there is no message between 2 accounts"
    end

    def self.call(accountA_info:, accountB_info:)
      accountA = Account.find(account: accountA_info)
      accountB = Account.find(account: accountB_info)

      sended_message = AccountsAccount.first(sender_id: accountA.account_id,
                                             receiver_id: accountB.account_id)
      receiver_message = AccountsAccount.first(sender_id: accountB.account_id,
                                             receiver_id: accountA.account_id)
      
      raise NoMessageError if sended_message.nil? & receiver_message.nil?
      return receiver_message.chats if sended_message.nil?
      return sended_message.chats if receiver_message.nil?
      
      sended_message.chats + receiver_message.chats
    end
  end
end