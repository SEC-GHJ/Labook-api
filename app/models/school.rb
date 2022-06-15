# frozen_string_literal: true

require 'json'
require 'sequel'

module Labook
  # Models a lab
  class School < Sequel::Model
    one_to_many :departments, class: :'Labook::Department', key: :school_name

    plugin :association_dependencies,
           departments: :destroy
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :school_name

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'school',
          attributes: {
            school_name:
          },
          include: {
            departments:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
