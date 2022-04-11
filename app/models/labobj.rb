# frozen_string_literal: true

require 'json'
require 'sequel'

module Labook
  # Models a lab
  class LabObj < Sequel::Model
    one_to_many :posts
    plugin :association_dependencies, documents: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'labobj',
            attributes: {
              lab_id:,
              lab_name:,
              school:,
              department:,
              professor:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
