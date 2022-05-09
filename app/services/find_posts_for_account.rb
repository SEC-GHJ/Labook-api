# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class FindPostsForAccount
    # no existent lab
    class AccountNotFoundError < StandardError
      def message = 'Account cannot be found'
    end

    def self.call(account:)
      account = Account.first(account:)
      raise(AccountNotFoundError) if account.nil?

      AccountsLab.where(poster_id: account.account_id).all.map(&:posts)
    end
  end
end
