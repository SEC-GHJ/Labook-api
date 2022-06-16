# frozen_string_literal: true

module Labook
  # Service object to find or create lab
  class FindOrCreateLab
    # Can not save lab
    class SaveLabError < StandardError
      def message = 'Could not save lab';
    end
    def self.find(lab_data)
      Lab.first(lab_name: lab_data['lab_name'],
                school_name: lab_data['school_name'],
                department_name: lab_data['department_name'],
                professor: lab_data['professor'])
    end

    def self.call(lab_data)
      lab = find(lab_data)
      return lab if lab

      new_lab = Lab.new(lab_data)
      raise SaveLabError unless new_lab.save

      new_lab
    end
  end
end
