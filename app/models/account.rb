# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'
require_relative '../lib/secure_db'

module Labook
  # Models a registered account
  class Account < Sequel::Model
    # account and account have many_to_many relationships on chat
    many_to_many :sended_accounts,
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
           sended_accounts: :nullify,
           received_accounts: :nullify,
           commented_labs: :nullify,
           voted_posts: :nullify,
           commented_posts: :nullify,
           voted_comments: :nullify
    

    plugin :uuid, field: :account_id
    plugin :whitelist_security
    set_allowed_columns :username, :gpa, :ori_school, :ori_department, :password, :email,
                        :line_id, :account_id, :nickname, :show_all, :accept_mail,
                        :line_notify_access_token

    plugin :timestamps, update_on_create: true

    def mailed_accounts
      sended_accounts + received_accounts
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Labook::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def line_notify_access_token
      SecureDB.decrypt(line_notify_access_token_secure)
    end

    def line_notify_access_token=(plaintext)
      self.line_notify_access_token_secure = SecureDB.encrypt(plaintext)
    end

    # def self.create_line_account(line_account)
    #   create(username: line_account[:username],
    #          email: line_account[:email],
    #          line_access_token: line_account[:line_access_token])
    # end

    def can_notify
      !line_notify_access_token.nil?
    end

    def to_h
      {
        type: 'account',
        attributes: {
          account_id:,
          username:,
          nickname:,
          gpa:,
          ori_school:,
          ori_department:,
          email:,
          show_all:,
          accept_mail:,
          can_notify:
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
    
    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
