# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:labs) do
      primary_key :lab_id

      String :lab_name, null: false
      String :school, null: false
      String :department, null: false
      String :professor, null: false
    end
  end
end