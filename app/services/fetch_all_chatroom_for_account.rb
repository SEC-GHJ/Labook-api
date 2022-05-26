# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchAllChatroomsForAccount
    def self.call(account:)
      owner = Account.first(account:)
      
      owner.mailed_accounts.uniq
    end
  end
end