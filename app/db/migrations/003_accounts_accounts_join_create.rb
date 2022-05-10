# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # create_join_table(sender_id: :accounts, receiver_id: :accounts)
    create_table(:accounts_accounts) do
      foreign_key :sender_id, :accounts
      foreign_key :receiver_id, :accounts
      primary_key [:sender_id, :receiver_id]
      index [:sender_id, :receiver_id]
    end
  end
end
