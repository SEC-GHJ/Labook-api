# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # create_join_table(voter_id: :accounts, voted_post_id: :comments)
    create_table(:accounts_comments) do
      foreign_key :voter_id, :accounts, type: :uuid
      foreign_key :voted_comment_id, :comments
      primary_key [:voter_id, :voted_comment_id]
      index [:voter_id, :voted_comment_id]
    end
  end
end
