# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('chats') do |routing|
      @chat_route = "#{@api_root}/chats"

      routing.on String do |account_id|
        # POST /api/v1/chats/[account_id]
        routing.post do
          content = JSON.parse(routing.body.read)["content"]
          receiver = Account.find(account_id:)
          raise("receiver not found") if receiver.nil?

          chat = CreateChat.call(sender_account: @auth_account['username'],
                                 receiver_account: receiver.username,
                                 content:)
          chat ? chat.to_json : raise
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{post_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end

        # GET /api/v1/chats/[account_id]
        routing.get do
          accountB_info = Account.first(account_id:)
          raise("accountB_info not found") if accountB_info.nil?

          chats = FetchMessagesForChatroom.call(accountA_info: @auth_account['username'],
                                                accountB_info: accountB_info.username)
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
          routing.halt 404, { message: e.message }.to_json
        end
      end
    end
  end
end
