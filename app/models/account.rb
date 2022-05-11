# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Labook
  # Models a registered account
  class Account < Sequel::Model
    # one_to_many :commented_labs, class: :'Labook::Post', key: :poster_id

    # one_to_many :sened_accounts, class: :'Labook::Chat', key: :sender_id
    # one_to_many :received_accounts, class: :'Labook::Chat', key: :receiver_id

    # account and lab have many_to_many relationships on post
    many_to_many :commented_labs,
                 class: :'Labook::Lab',
                 join_table: :accounts_labs,
                 left_key: :poster_id, right_key: :lab_id

    # account and account have many_to_many relationships on chat
    many_to_many :sened_accounts,
                 class: self,
                 join_table: :accounts_accounts,
                 left_key: :sender_id, right_key: :receiver_id

    many_to_many :received_accounts,
                 class: self,
                 join_table: :accounts_accounts,
                 left_key: :receiver_id, right_key: :sender_id

    # account and post have many_to_many relationships on vote
    many_to_many :voted_posts,
                 class: :'Labook::Post',
                 join_table: :accounts_posts,
                 left_key: :voter_id, right_key: :voted_post_id

    plugin :association_dependencies,
           commented_labs: :nullify,
           sened_accounts: :nullify,
           received_accounts: :nullify

    plugin :whitelist_security
    set_allowed_columns :account, :gpa, :ori_school, :ori_department, :password

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

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            account:,
            gpa:,
            ori_school:,
            ori_department:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
