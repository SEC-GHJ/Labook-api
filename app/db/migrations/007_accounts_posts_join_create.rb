# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # create_join_table(voter_id: :accounts, voted_post_id: :posts)
    create_table(:accounts_posts) do
      foreign_key :voter_id, :accounts
      foreign_key :voted_post_id, :posts, type: :uuid
      primary_key [:voter_id, :voted_post_id]
      index [:voter_id, :voted_post_id]
    end
  end
end
