# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchLabs
    def self.call
      all_department = Department.all
      all_labs = []
      all_department.each do |department|
        department_lab = Lab.where(department_name: department.department_name).all
        # extend the list
        all_labs += department_lab
      end
      all_labs
    end
  end
end
