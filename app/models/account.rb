# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Labook
  # Models a registered account
  class Account < Sequel::Model
    # one_to_many :owned_posts, class: :'Labook::Post', key: :poster_id

    # one_to_many :sended_chats, class: :'Labook::Chat', key: :sender_id
    # one_to_many :received_chats, class: :'Labook::Chat', key: :receiver_id

    # account and lab have many_to_many relationships on post
    many_to_many :owned_posts,
                 class: :'Labook::Lab',
                 join_table: :accounts_labs,
                 left_key: :poster_id, right_key: :lab_id

    # account and account have many_to_many relationships on chat
    many_to_many :sended_chats,
                 class: self,
                 join_table: :accounts_accounts,
                 left_key: :sender_id, right_key: :receiver_id

    many_to_many :received_chats,
                 class: self,
                 join_table: :accounts_accounts,
                 left_key: :receiver_id, right_key: :sender_id

    plugin :association_dependencies,
            owned_posts: :nullify,
            sended_chats: :nullify,
            received_chats: :nullify


    plugin :whitelist_security
    set_allowed_columns :account, :gpa, :ori_school, :ori_department, :password

    plugin :timestamps, update_on_create: true

    def posts
      owned_posts
    end

    def chats
      sended_chats + received_chats
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Labook::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          account_id:,
          account:,
          gpa:,
          ori_school:,
          ori_department:
        }, options
      )
    end
  end
end
