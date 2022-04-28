# frozen_string_literal: true

module Labook
  # Service object to create chat for account and account
  class CreateChat
    class SenderNotReceiverError < StandardError
      def message = 'Sender cannot be receiver'
    end

    def self.call(sender_id:, receiver_id:, content:)
      sender = Account.first(account_id: sender_id)
      receiver = Account.first(account_id: receiver_id)
      raise(SenderNotReceiverError) if sender_id == receiver_id

      sender.add_sended_chat(receiver)
      AccountsAccount.first(sender_id:, receiver_id:).add_chat(content)
    end
  end
end