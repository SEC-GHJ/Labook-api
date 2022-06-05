# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:labs) do
      uuid :lab_id, primary_key: true

      String :lab_name, null: false
      String :school, null: false
      String :department, null: false
      String :professor, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
