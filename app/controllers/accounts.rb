# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on 'setting' do
        routing.patch do
          raise('No auth_token is given or token is invalid.') if @auth_account.nil?

          account = Account.first(account_id: @auth_account['account_id'])
          raise('auth_token\'s account is error') if account.nil?

          setting_data = JSON.parse(routing.body.read)

          new_setting = UpdateAccountSetting.call(account:, setting_data:)
          new_setting ? new_setting.to_json : raise('Server error - can not update account setting')
        rescue UpdateAccountSetting::NoUpdate
          routing.halt 204
        rescue StandardError => e
          Api.logger.error(e.message)
          routing.halt 404, { message: e.message }.to_json
        end
      end

      routing.on String do |account_id|
        # routing.on 'posts' do
        #   # GET api/v1/accounts/[account_id]/posts
        #   routing.get do
        #     output = { data: FindPostsForAccount.call(account_id:) }
        #     JSON.pretty_generate(output)
        #   rescue StandardError => e
        #     Api.logger.error(e.message)
        #     routing.halt 404, 'Could not find all posts'
        #   end
        # end

        # routing.on 'votes' do
        #   # GET api/v1/accounts/[account_id]/votes
        #   routing.get do
        #     output = { data: FindVotesForAccount.call(account_id:) }
        #     JSON.pretty_generate(output)
        #   rescue StandardError => e
        #     Api.logger.error(e.message)
        #     routing.halt 404, { message: e.message }.to_json
        #   end
        # end

        # POST api/v1/accounts/[account_id]/contact
        routing.on 'contact' do
          routing.post do
            receiver = Account.find(account_id:)
            raise('receiver account not found') if receiver.nil?

            chatroom = FindOrCreateChatroom.call(sender_account: @auth_account['username'],
                                                 receiver_account: receiver.username)
            chatroom ? chatroom.to_json : raise('Server error')
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{post_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error(e.message)
            routing.halt 404, { message: e.message }.to_json
          end
        end

        # GET api/v1/accounts/[account_id]
        routing.get do
          raise('No auth_token is given or token is invalid.') if @auth_account.nil?

          requestor = Account.first(account_id: @auth_account['account_id'])
          raise('auth_token\'s account is error') if requestor.nil?

          account = Account.first(account_id:)
          raise('Account not found') if account.nil?

          policy = AccountPolicy.new(requestor, account)
          raise('Unauthorized Request Error') unless policy.can_view?

          account.to_h.merge(policies: policy.summary).to_json
        rescue StandardError => e
          Api.logger.error(e.message)
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.is do
        routing.post do
          new_data = SignedRequest.new(Api.config).parse(routing.body.read)
          new_account = Account.new(new_data)
          raise('Could not save account') unless new_account.save

          response.status = 201
          response['Location'] = "#{@account_route}/#{new_account.account_id}"
          { message: 'Account created', data: new_account }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => e
          Api.logger.error "Unknown error saving account: #{e.message}"
          routing.halt 500, { message: e.message }.to_json
        end
      end
    end
  end
end
