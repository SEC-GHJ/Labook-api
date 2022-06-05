# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class FindPostsForAccount
    # no existent lab
    class AccountNotFoundError < StandardError
      def message = 'Account cannot be found'
    end

    def self.call(username:)
      account = Account.first(username:)
      raise(AccountNotFoundError) if account.nil?

      # AccountsLab.where(poster_id: account.account_id).map(&:posts)
      AccountsLab.find(poster_id: account.account_id).posts
    end
  end
end
