# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:schools) do
      String :school_name, primary_key: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
