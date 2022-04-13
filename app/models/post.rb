# frozen_string_literal: true

require 'json'
require 'sequel'

module Labook
  # Holds a full secret post
  class Post < Sequel::Model
    many_to_one :lab

    plugin :timestamps

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
