# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class FindPostsForLab
    # no existent lab
    class LabNotFoundError < StandardError
      def message = 'Lab cannot be found'
    end

    def self.call(lab_id:)
      lab = Lab.first(lab_id:)
      raise(LabNotFoundError) if lab.nil?


      AccountsLab.where(lab_id:).all.map(&:posts).flatten
    end
  end
end
