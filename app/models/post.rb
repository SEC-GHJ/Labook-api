# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class Post < Sequel::Model
    many_to_one :accounts_lab, class: :'Labook::AccountsLab', key: %i[poster_id lab_id]

    # account and post have many_to_many relationships on PostVote
    many_to_many :voted_accounts,
                 class: :'Labook::Account',
                 join_table: :accounts_posts,
                 left_key: :voted_post_id, right_key: :voter_id

    # account and post have many_to_many relationships on comment
    many_to_many :commented_accounts,
                 class: :'Labook::Account',
                 join_table: :accounts_comment_posts,
                 left_key: :commented_post_id, right_key: :commenter_id

    plugin :uuid, field: :post_id
    plugin :timestamps
    plugin :whitelist_security
    plugin :association_dependencies,
           voted_accounts: :nullify,
           commented_accounts: :nullify

    set_allowed_columns :lab_score, :professor_attitude, :content, :accept_mail, :vote_sum

    def lab_info
      Lab.first(lab_id:)
    end

    def comments
      AccountsCommentPost.where(commented_post_id: post_id).all.map(&:comments)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'post',
          attributes: {
            post_id:,
            lab_id:,
            poster_id:,
            lab_score:,
            professor_attitude:,
            content:,
            accept_mail:,
            vote_sum:,
            created_at:,
          },
          include: {
            lab_info:,
            comments:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
