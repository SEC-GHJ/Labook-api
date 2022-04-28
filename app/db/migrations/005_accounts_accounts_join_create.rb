# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(sender_id: :accounts, receiver_id: :accounts)
  end
end
