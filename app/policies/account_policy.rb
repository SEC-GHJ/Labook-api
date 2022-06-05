# frozen_string_literal: true

module Labook
  # Policy to determine if account can view a project
  class AccountPolicy
    def initialize(requestor, account)
      @requestor = requestor
      @account = account
    end

    def can_view?
      (self_request? || show_all?) && !@requestor.nil?
    end

    def can_edit?
      (self_request?) && !@requestor.nil?
    end

    def can_delete?
      false
    end

    def can_mail?
      (!self_request? && accept_mail?) && !@requestor.nil?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_mail: can_mail?
      }
    end

    private

    def self_request?
      @requestor == @account
    end

    def show_all?
      @account.show_all == 1
    end

    def accept_mail?
      @account.accept_mail == 1
    end
  end
end