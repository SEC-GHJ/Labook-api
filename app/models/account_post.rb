# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class AccountsPost < Sequel::Model
    one_to_many :votes, class: :'Labook::PostVote',
                        key: %i[voter_id voted_post_id]

    plugin :uuid, field: :voted_post_id
    plugin :uuid, field: :voter_id
    plugin :association_dependencies,
           votes: :destroy

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'accounts_posts',
          attributes: {
            voter_id:,
            voted_post_id:
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
