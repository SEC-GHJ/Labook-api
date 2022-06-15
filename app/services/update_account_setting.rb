# frozen_string_literal: true

module Labook
  # Service object to update account setting
  class UpdateAccountSetting
    # No need to update account
    class NoUpdate < StandardError
      def message
        'Account setting remains the same.'
      end
    end

    def self.call(account:, setting_data:)
      new_account = account.update(setting_data)
      raise NoUpdate if new_account.nil?

      new_account
    end
  end
end
