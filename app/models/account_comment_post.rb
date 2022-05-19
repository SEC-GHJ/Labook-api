# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class AccountsCommentPost < Sequel::Model
    one_to_many :comments, class: :'Labook::Comment',
                           key: %i[commenter_id commented_post_id]

    plugin :association_dependencies,
           comments: :destroy

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'accounts_comment_posts',
          attributes: {
            commenter_id:,
            commented_post_id:
          },
          include: {
            comments:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
