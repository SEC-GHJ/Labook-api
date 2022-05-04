# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:posts) do
      primary_key :post_id
      Integer :poster_id
      Integer :lab_id
      foreign_key [:poster_id, :lab_id], table: :accounts_labs, name: 'posts_poster_lab_fkey' # name is optional

      String :lab_score_secure, null: false
      String :professor_attitude_secure, null: false
      String :content_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
