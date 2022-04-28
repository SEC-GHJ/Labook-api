# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(poster_id: :accounts, lab_id: :labs)
  end
end
