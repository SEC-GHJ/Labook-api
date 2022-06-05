# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class CreatePost
    # no existent account error
    class PosterNotFoundError < StandardError
      def message = 'Poster cannot be found'
    end

    # no existent lab error
    class LabNotFoundError < StandardError
      def message = 'Lab cannot be found'
    end

    def self.call(poster_account:, lab_id:, post_data:)
      account = Account.first(username: poster_account)
      raise(PosterNotFoundError) if account.nil?

      lab = Lab.first(lab_id:)
      raise(LabNotFoundError) if lab.nil?

      account.add_commented_lab(lab)

      AccountsLab.first(lab_id: lab.lab_id, poster_id: account.account_id)
                 .add_post(post_data)
    end
  end
end
