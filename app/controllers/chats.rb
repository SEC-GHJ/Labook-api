# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('chats') do |routing|
      @chat_route = "#{@api_root}/chats"

      routing.on String do |username|
        # POST /api/v1/chats/[username]
        routing.post do
          content = JSON.parse(routing.body.read)["content"]
          chat = CreateChat.call(sender_account: @auth_account['account'],
                                 receiver_account: username,
                                 content:)
          chat ? chat.to_json : raise
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end

        # GET /api/v1/chats/[username]
        routing.get do
          chats = FetchMessagesForChatroom.call(accountA_info: @auth_account['account'],
                                                accountB_info: username)
          chats ? chats.to_json : raise
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      routing.is do
        # GET /api/v1/chats
        routing.get do
          chatrooms = FetchAllChatroomsForAccount.call(account: @auth_account['account'])
          chatrooms ? chatrooms.to_json : raise
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end
    end
  end
end
