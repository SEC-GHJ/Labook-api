# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :comment_id
      Integer :commenter_id
      Integer :commented_post_id
      foreign_key [:commenter_id, :commented_post_id], table: :accounts_comment_posts

      String :content_secure, null: false
      Integer :accept_mail, null: false
      Integer :vote_sum, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end