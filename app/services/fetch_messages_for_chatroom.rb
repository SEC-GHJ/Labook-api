# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchMessagesForChatroom
    # There is no message between accounts
    class NoMessageError < StandardError
      def message = 'there is no message between 2 accounts'
    end

    # Given account does not exist
    class InvalidAccount < StandardError
      def message = 'Given account is invalid.'
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.call(account_a_info:, account_b_info:)
      account_a = Account.find(username: account_a_info)
      account_b = Account.find(username: account_b_info)
      raise InvalidAccount if account_a.nil? || account_b.nil?

      sended_message = AccountsAccount.first(sender_id: account_a.account_id,
                                             receiver_id: account_b.account_id)
      receiver_message = AccountsAccount.first(sender_id: account_b.account_id,
                                               receiver_id: account_a.account_id)

      raise NoMessageError if sended_message.nil? & receiver_message.nil?
      return receiver_message.chats if sended_message.nil?
      return sended_message.chats if receiver_message.nil?

      all_messages = sended_message.chats + receiver_message.chats
      all_messages.sort_by!(&:created_at)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
