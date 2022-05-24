# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret comment
  class Comment < Sequel::Model
    many_to_one :accounts_comment_post, class: :'Labook::AccountsCommentPost', key: %i[commenter_id commented_post_id]

    # account and comment have many_to_many relationships on CommentVote
    many_to_many :voted_accounts,
                 class: :'Labook::Account',
                 join_table: :accounts_comments,
                 left_key: :voted_comment_id, right_key: :voter_id
    
    plugin :uuid, field: :commented_post_id              
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :content, :accept_mail, :vote_sum

    def content
      SecureDB.decrypt content_secure
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'comment',
          attributes: {
            comment_id:,
            commenter_id:,
            commented_post_id:,
            content:,
            accept_mail:,
            vote_sum:,
            created_at:,
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
