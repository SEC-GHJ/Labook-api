# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:departments) do
      foreign_key :school_name, :schools, type: :String

      String :department_name, null: false

      primary_key [:school_name, :department_name]
      index [:school_name, :department_name]

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
