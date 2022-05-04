# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class Post < Sequel::Model
    # many_to_one :lab, class: :'Labook::Lab', key: :lab_id
    # many_to_one :account, class: :'Labook::Account', key: :poster_id

    many_to_one :accounts_lab, class: :'Labook::AccountsLab', key: [:poster_id, :lab_id]

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :lab_score, :professor_attitude, :content


    def lab_score
      SecureDB.decrypt(lab_score_secure)
    end

    def lab_score=(plaintext)
      self.lab_score_secure = SecureDB.encrypt(plaintext)
    end

    def professor_attitude
      SecureDB.decrypt(professor_attitude_secure)
    end

    def professor_attitude=(plaintext)
      self.professor_attitude_secure = SecureDB.encrypt(plaintext)
    end

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
          type: 'post',
          attributes: {
            post_id:,
            lab_id:,
            poster_id:,
            lab_score:,
            professor_attitude:,
            content:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
