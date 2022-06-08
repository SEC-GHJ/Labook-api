# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:labs) do
      uuid :lab_id, primary_key: true

      String :school_name
      String :department_name
      foreign_key [:school_name, :department_name], :departments

      String :lab_name, null: true
      String :professor, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
