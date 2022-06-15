# frozen_string_literal: true

module Labook
  # Service object to fetch all chatrooms
  class FetchAllChatroomsForAccount
    def self.call(username:)
      owner = Account.first(username:)

      Chatrooms.new(owner)
    end
  end
end
