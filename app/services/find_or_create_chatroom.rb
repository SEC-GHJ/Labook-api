# frozen_string_literal: true

module Labook
  # Service object to create chatroom for account and account
  class FindOrCreateChatroom
    # sender = receiver error
    class SenderNotReceiverError < StandardError
      def message = 'Sender cannot be receiver'
    end

    def self.call(sender_account:, receiver_account:)
      raise SenderNotReceiverError if sender_account == receiver_account

      sender = Account.find(username: sender_account)
      receiver = Account.find(username: receiver_account)

      # check whether connection is built
      connection = AccountsAccount.first(sender_id: sender.account_id,
                                         receiver_id: receiver.account_id)
      if connection.nil?
        sender.add_sended_account(receiver)
        connection = AccountsAccount.first(sender_id: sender.account_id,
                                           receiver_id: receiver.account_id)
      end

      connection
    end
  end
end
