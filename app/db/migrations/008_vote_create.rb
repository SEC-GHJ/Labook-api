# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:votes) do
      primary_key :vote_id
      Integer :voter_id
      Integer :voted_post_id
      foreign_key [:voter_id, :voted_post_id], :accounts_posts, name: 'votes_voter_voted_fkey' # name is optional

      Integer :number, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
