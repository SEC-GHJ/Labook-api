# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class AccountsLab < Sequel::Model
    one_to_many :posts, class: :'Labook::Post', key: %i[poster_id lab_id]
    plugin :association_dependencies,
           posts: :destroy
    plugin :uuid, field: :poster_id
    plugin :uuid, field: :lab_id

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'accounts_labs',
          attributes: {
            poster_id:,
            lab_id:
          },
          include: {
            posts:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
