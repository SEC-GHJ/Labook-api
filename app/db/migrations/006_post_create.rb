# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:posts) do
      uuid :post_id, primary_key: true
      Integer :poster_id
      Integer :lab_id
      foreign_key [:poster_id, :lab_id], table: :accounts_labs, name: 'posts_poster_lab_fkey' # name is optional

      Integer :lab_score, null: false
      String :professor_attitude, null: false
      String :content, null: false
      Integer :accept_mail, null: false
      Integer :vote_sum, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
