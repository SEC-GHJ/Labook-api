# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative '../lib/secure_db'

module Labook
  # Holds a full secret post
  class Vote < Sequel::Model
    many_to_one :accounts_post, class: :'Labook::AccountsPost',
                                key: %i[voter_id voted_post_id]

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :number

    def to_json(options = {})
      JSON(
        {
          type: 'vote',
          attributes: {
            vote_id:,
            number:
          }
        }, options
      )
    end
  end
end
