# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Labook
  # Models a registered account
  class Account < Sequel::Model
    # account and account have many_to_many relationships on chat
    many_to_many :sened_accounts,
                 class: self,
                 join_table: :accounts_accounts,
                 left_key: :sender_id, right_key: :receiver_id

    many_to_many :received_accounts,
                 class: self,
                 join_table: :accounts_accounts,
                 left_key: :receiver_id, right_key: :sender_id

    # account and lab have many_to_many relationships on post
    many_to_many :commented_labs,
                 class: :'Labook::Lab',
                 join_table: :accounts_labs,
                 left_key: :poster_id, right_key: :lab_id

    # account and post have many_to_many relationships on PostVote
    many_to_many :voted_posts,
                 class: :'Labook::Post',
                 join_table: :accounts_posts,
                 left_key: :voter_id, right_key: :voted_post_id

    # account and post have many_to_many relationships on comment
    many_to_many :commented_posts,
                 class: :'Labook::Post',
                 join_table: :accounts_comment_posts,
                 left_key: :commenter_id, right_key: :commented_post_id

    # account and comment have many_to_many relationships on CommentVote
    many_to_many :voted_comments,
                 class: :'Labook::Comment',
                 join_table: :accounts_comments,
                 left_key: :voter_id, right_key: :voted_comment_id

    plugin :association_dependencies,
            sened_accounts: :nullify,
            received_accounts: :nullify,
            commented_labs: :nullify,
            voted_posts: :nullify,
            commented_posts: :nullify,
            voted_comments: :nullify
           
    plugin :whitelist_security
    set_allowed_columns :account, :gpa, :ori_school, :ori_department, :password, :email, :line_access_token

    plugin :timestamps, update_on_create: true

    def mailed_accounts
      sened_accounts + received_accounts
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Labook::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def email
      SecureDB.decrypt(email_secure)
    end

    def email=(plaintext)
      self.email_secure = SecureDB.encrypt(plaintext)
    end

    def line_access_token
      SecureDB.decrypt(line_access_token_secure)
    end

    def line_access_token=(plaintext)
      self.line_access_token_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            account:,
            gpa:,
            ori_school:,
            ori_department:,
            email:,
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
