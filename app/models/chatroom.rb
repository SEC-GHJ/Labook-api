# frozen_string_literal: true

module Labook
  # Behaviors of the all the chatrooms
  class Chatroom
    attr_reader :username, :account_id

    def initialize(chat_info)
      @username = chat_info['attributes']['username']
      @account_id = chat_info['attributes']['account_id']
    end
  end
end
