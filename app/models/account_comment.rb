# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret comment
  class AccountsComment < Sequel::Model
    one_to_many :votes, class: :'Labook::CommentVote',
                        key: %i[voter_id voted_comment_id]

    plugin :association_dependencies,
           votes: :destroy

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'accounts_comments',
          attributes: {
            voter_id:,
            voted_comment_id:
          },
          include: {
            vote:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
