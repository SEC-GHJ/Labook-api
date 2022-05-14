# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comment_votes) do
      primary_key :vote_id
      Integer :voter_id
      Integer :voted_comment_id
      foreign_key [:voter_id, :voted_comment_id], :accounts_comments

      Integer :number, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
