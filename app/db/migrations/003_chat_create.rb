# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:chats) do
      primary_key :chat_id
      foreign_key :sender_id, :accounts
      foreign_key :receiver_id, :accounts  

      String :content_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
