# frozen_string_literal: true

require 'json'
require 'sequel'

module Labook
  # Models a lab
  class Department < Sequel::Model
    many_to_one :school, class: :'Labook::School', key: :department_name
    one_to_many :labs, class: :'Labook::Lab', key: %i[school_name department_name]

    plugin :association_dependencies,
           labs: :destroy


    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :department_name, :school_name


    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'department',
          attributes: {
            school_name:,
            department_name:
          },
          include: {
            labs:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
