# frozen_string_literal: true

module Labook
  # Service object to create chat for account and account
  class CreateChat
    # sender = receiver error
    class SenderNotReceiverError < StandardError
      def message = 'Sender cannot be receiver'
    end

    # sender = receiver error
    class ChatroomNotFound < StandardError
      def message = 'chatroom cannot be found'
    end

    # sender = receiver error
    class UserNotFound < StandardError
      def message = 'user cannot be found'
    end

    def self.check_account_valid(account:)
      account_valid = Account.find(account:)
      raise UserNotFound if account_valid.nil?
      
      account_valid
    end

    # rubocop:disable Metrics/MethodLength
    def self.call(sender_account:, receiver_account:, content:)
      sender = check_account_valid(account: sender_account)
      receiver = check_account_valid(account: receiver_account)
      raise(SenderNotReceiverError) if sender.account_id == receiver.account_id

      # check whether connection is built
      connection = AccountsAccount.first(sender_id: sender.account_id,
                                         receiver_id: receiver.account_id)
      raise ChatroomNotFound if connection.nil?
      connection.add_chat(content:)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
