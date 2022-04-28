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
      sender = Labook::Account.find(account: chat_data['sender_account'])
      receiver = Labook::Account.find(account: chat_data['receiver_account'])
      new_chat = Labook::CreateChat.call(
        sender_id: sender.account_id,
        receiver_id: receiver.account_id,
        content: chat_data['content']
      )
      
      chat = Labook::Chat.find(chat_id: new_chat.chat_id)
      _(chat.sender_id).must_equal chat_data['sender_account']
      _(chat.receiver_id).must_equal chat_data['receiver_account']
      _(chat.content).must_equal chat_data['content']
    end
  end

  it 'SECURITY: should secure sensitive attributes' do
    DATA[:chats].each do |chat_data|
      sender = Labook::Account.find(account: chat_data['sender_account'])
      receiver = Labook::Account.find(account: chat_data['receiver_account'])
      new_chat = Labook::CreateChat.call(
        sender_id: sender.account_id,
        receiver_id: receiver.account_id,
        content: chat_data['content']
      )
      
      stored_chat = Labook::Chat.find(chat_id: new_chat.chat_id)
      _(stored_chat[:content_secure]).wont_equal new_chat.content
    end
  end
end
