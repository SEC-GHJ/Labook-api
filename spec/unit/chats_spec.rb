# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Chat Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    DATA[:chats].each do |chat_data|
      new_chat = Labook::CreateChat.call(
        sender_account: chat_data['sender_account'],
        receiver_account: chat_data['receiver_account'],
        content: chat_data['content']
      )
      
      chat = Labook::Chat.find(chat_id: new_chat.chat_id)
      sender_id = Labook::Account.find(account: chat_data['sender_account']).account_id
      receiver_id = Labook::Account.find(account: chat_data['receiver_account']).account_id
      # puts "#{chat.sender_id} == #{sender_id}"
      # puts "#{chat.receiver_id} == #{receiver_id}"
      _(chat.sender_id).must_equal sender_id
      _(chat.receiver_id).must_equal receiver_id
      _(chat.content).must_equal chat_data['content']
    end
  end

  it 'SECURITY: should secure sensitive attributes' do
    DATA[:chats].each do |chat_data|
      new_chat = Labook::CreateChat.call(
        sender_account: chat_data['sender_account'],
        receiver_account: chat_data['receiver_account'],
        content: chat_data['content']
      )
      
      stored_chat = Labook::Chat.find(chat_id: new_chat.chat_id)
      _(stored_chat[:content_secure]).wont_equal new_chat.content
    end
  end
end
