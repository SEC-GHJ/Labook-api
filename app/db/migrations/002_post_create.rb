# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:posts) do
      primary_key :post_id
      foreign_key :lab_id, table: :labs

      String :user_id, null: false
      String :lab_score, null: false
      String :professor_attitude, null: false
      String :content, null: false

      DateTime :created_at
      DateTime :updated_at
      
    end
  end
end