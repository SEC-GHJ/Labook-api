# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('comments') do |routing|
      @account_route = "#{@api_root}/comments"

      # POST /api/v1/posts/[comment_id]/votes
      routing.on String do |comment_id|
        routing.on 'votes' do
          raise('No auth_token is given or token is invalid.') if @auth_account.nil?

          number = JSON.parse(routing.body.read)["number"].to_i
          vote = CreateCommentVote.call(voter_account: @auth_account['username'], voted_comment_id: comment_id, number:)
          vote.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{post_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error e.message
          routing.halt 500, { message: e.message }.to_json
        end
      end
    end
  end
end
