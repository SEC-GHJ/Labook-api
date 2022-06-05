# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchAllChatroomsForAccount
    def self.call(username:)
      owner = Account.first(username:)
      
      owner.mailed_accounts.uniq
    end
  end
end