# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('chats') do |routing|
      @chat_route = "#{@api_root}/chats"

      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      routing.on String do |account_id|
        # POST /api/v1/chats/[account_id]
        routing.post do
          content = JSON.parse(routing.body.read)['content']
          receiver = Account.find(account_id:)
          raise('receiver not found') if receiver.nil?

          chat = CreateChat.call(sender_account: @auth_account['username'],
                                 receiver_account: receiver.username,
                                 content:)
          chat ? chat.to_json : raise
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end

        # GET /api/v1/chats/[account_id]
        routing.get do
          account_b_info = Account.first(account_id:)
          raise('account_b_info not found') if account_b_info.nil?

          chats = FetchMessagesForChatroom.call(account_a_info: @auth_account['username'],
                                                account_b_info: account_b_info.username)
          chats ? chats.to_json : raise
        rescue StandardError => e
          Api.logger.error(e.message)
          routing.halt 404, { message: e.message }.to_json
        end
      end

      routing.is do
        # GET /api/v1/chats
        routing.get do
          chatrooms = FetchAllChatroomsForAccount.call(username: @auth_account['username'])
          chatrooms ? chatrooms.to_json : raise
        rescue StandardError => e
          Api.logger.error(e.message)
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
