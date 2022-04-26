# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Labook
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_labs, class: :'Labook::Lab', key: :owner_account_id
    many_to_many :collaborations,
                 class: :'Labook::Lab',
                 join_table: :accounts_labs,
                 left_key: :poster_id, right_key: :lab_id

    plugin :association_dependencies,
           owned_labs: :destroy,
           collaborations: :nullify

    plugin :whitelist_security
    set_allowed_columns :account, :gpa, :ori_school, :ori_department

    plugin :timestamps, update_on_create: true

    def labs
      owned_labs + collaborations
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
