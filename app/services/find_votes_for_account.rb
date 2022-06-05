# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class FindVotesForAccount
    # no existent lab
    class AccountNotFoundError < StandardError
      def message = 'Account cannot be found'
    end

    def self.call(account_id:)
      account = Account.first(account_id:)
      raise(AccountNotFoundError) if account.nil?

      AccountsPost.where(voter_id: account_id).all.map(&:votes)
    end
  end
end
