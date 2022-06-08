# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:chats) do
      primary_key :chat_id
      uuid :sender_id
      uuid :receiver_id
      foreign_key [:sender_id, :receiver_id], :accounts_accounts, name: 'chats_sender_receiver_fkey' # name is optional

      String :content_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
