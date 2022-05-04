# frozen_string_literal: true

module Labook
  # Service object to create chat for account and account
  class CreateChat
    # sender = receiver error
    class SenderNotReceiverError < StandardError
      def message = 'Sender cannot be receiver'
    end

    # rubocop:disable Metrics/MethodLength
    def self.call(sender_account:, receiver_account:, content:)
      sender = Account.find(account: sender_account)
      receiver = Account.find(account: receiver_account)
      raise(SenderNotReceiverError) if sender.account_id == receiver.account_id

      # check whether connection is built
      connection = AccountsAccount.first(sender_id: sender.account_id,
                                         receiver_id: receiver.account_id)
      if connection.nil?
        sender.add_sended_chat(receiver)
        connection = AccountsAccount.first(sender_id: sender.account_id,
                                           receiver_id: receiver.account_id)
      end

      connection.add_chat(content:)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
