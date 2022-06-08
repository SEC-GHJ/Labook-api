# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # create_join_table(commenter_id: :accounts, commented_post_id: :posts)
    create_table(:accounts_comment_posts) do
      foreign_key :commenter_id, :accounts, type: :uuid
      foreign_key :commented_post_id, :posts, type: :uuid
      primary_key [:commenter_id, :commented_post_id]
      index [:commenter_id, :commented_post_id]
    end
  end
end
