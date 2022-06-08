# frozen_string_literal: true

require 'json'
require 'sequel'

module Labook
  # Models a lab
  class Lab < Sequel::Model
    many_to_one :department_obj, class: :'Labook::Department', key: %i[school_name department_name]

    # account and lab have many_to_many relationships on post
    many_to_many :commented_accounts,
                 class: :'Labook::Account',
                 join_table: :accounts_labs,
                 left_key: :lab_id, right_key: :poster_id

    plugin :association_dependencies,
           commented_accounts: :nullify

    plugin :timestamps
    plugin :whitelist_security
    plugin :uuid, field: :lab_id
    set_allowed_columns :lab_name, :school_name, :department_name, :professor

    def department
      department_name
    end

    def school
      school_name
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'lab',
          attributes: {
            lab_id:,
            lab_name:,
            department:,
            school:,
            professor:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
