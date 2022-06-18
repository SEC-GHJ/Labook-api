# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Chat Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end

    DATA[:chats].each do |chat_data|
      Labook::CreateChat.call(
        sender_account: chat_data['sender_account'],
        receiver_account: chat_data['receiver_account'],
        content: chat_data['content']
      )
    end

    @chat_data = DATA[:chats][0]
    @user1_data = DATA[:accounts][0]
    @user2_id = Labook::Account.first(
                  username: DATA[:accounts][1]['username']
                ).account_id
  end

  describe 'Getting Chatrooms for user' do
    it 'HAPPY: should get chatrooms for user' do
      header 'AUTHORIZATION', auth_header(@user1_data)
      get "/api/v1/chats"

      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result.count).must_equal 2

      first_chatroom = result[1]
      _(first_chatroom['type']).must_equal 'chatroom'
      _(first_chatroom['attributes']['username']).must_equal @chat_data['receiver_account']
    end

    it 'SAD AUTHORIZATION: should not process without authorization' do
      get "/api/v1/chats"
      _(last_response.status).must_equal 403
    end
  end

  describe 'Getting Chats for two accounts' do
    it 'HAPPY: should get messages for two accounts' do
      header 'AUTHORIZATION', auth_header(@user1_data)
      get "/api/v1/chats/#{@user2_id}"

      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result.count).must_equal 2
      
      first_chat = result[0]
      _(first_chat['type']).must_equal 'chat'
      _(first_chat['attributes']['content']).must_equal @chat_data['content']
    end

    it 'SAD: should return error if unknown account' do
      header 'AUTHORIZATION', auth_header(@user1_data)
      get "/api/v1/chats/123"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Chat for two accounts' do
    before do
      @message = {
        content: 'hello, a test'
      }
    end
    it 'HAPPY: should create new chat with other account' do
      header 'AUTHORIZATION', auth_header(@user1_data)
      post "/api/v1/chats/#{@user2_id}", @message.to_json

      user1_id = Labook::Account.first(username: @user1_data['username']).account_id

      _(last_response.status).must_equal 200
      attributes = JSON.parse(last_response.body)['attributes']
      _(attributes['content']).must_equal @message[:content]
      _(attributes['sender_id']).must_equal user1_id
    end

    it 'SAD: should return because receiver not found' do
      header 'AUTHORIZATION', auth_header(@user1_data)
      post "/api/v1/chats/123", @message.to_json

      _(last_response.status).must_equal 404
    end
  end
end