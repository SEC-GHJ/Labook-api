# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class Post < Sequel::Model
    many_to_one :lab

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :lab_score, :professor_attitude, :content, :user_id

    def user_id
      SecureDB.decrypt(user_id_secure)
    end

    def user_id=(plaintext)
      self.user_id_secure = SecureDB.encrypt(plaintext)
    end

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
          data: {
            type: 'post',
            attributes: {
              post_id:,
              user_id:,
              lab_score:,
              professor_attitude:,
              content:
            }
          },
          include: {
            lab:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
