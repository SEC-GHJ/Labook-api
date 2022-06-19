# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('comments') do |routing|
      @account_route = "#{@api_root}/comments"

      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      # POST /api/v1/comments/[comment_id]/votes
      routing.on String do |comment_id|
        routing.on 'votes' do
          number = JSON.parse(routing.body.read)['number'].to_i
          vote = CreateCommentVote.call(voter_account: @auth_account['username'], voted_comment_id: comment_id, number:)
          vote.to_json
        rescue StandardError => e
          Api.logger.error e.message
          routing.halt 500, { message: e.message }.to_json
        end
      end
    end
  end
end
