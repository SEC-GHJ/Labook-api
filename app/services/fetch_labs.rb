# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchLabs
    class NoMessageError < StandardError
      def message = "there is no message between 2 accounts"
    end

    class InvalidAccount < StandardError
      def message = "Given account is invalid."
    end

    def self.call
      all_department = Department.all
      all_labs = []
      all_department.each do |department|
        department_lab = Lab.where(department_name: department.department_name).all
        all_labs.push(department_lab)
      end
      all_labs
    end
  end
end
