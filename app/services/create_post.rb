# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class CreatePost
    class PosterNotFoundError < StandardError
      def message = 'Poster cannot be found'
    end

    class LabNotFoundError < StandardError
      def message = 'Lab cannot be found'
    end

    def self.call(poster_id:, lab_id:, post_data:)
      account = Account.first(account_id: poster_id)
      raise(PosterNotFoundError) if account.nil?
      lab = Lab.first(lab_id:)
      raise(LabNotFoundError) if lab.nil?
      
      account.add_owned_post(lab)

      AccountsLab.first(lab_id: lab.lab_id, poster_id: account.account_id)
                 .add_post(post_data)
    end
  end
end