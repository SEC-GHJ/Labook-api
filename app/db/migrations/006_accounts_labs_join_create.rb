# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # create_join_table(poster_id: :accounts, lab_id: :labs)
    create_table(:accounts_labs) do
      foreign_key :poster_id, :accounts
      foreign_key :lab_id, :labs
      primary_key [:poster_id, :lab_id]
      index [:poster_id, :lab_id]
    end
  end
end
