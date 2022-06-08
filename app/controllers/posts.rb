# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('posts') do |routing|
      @account_route = "#{@api_root}/posts"
      # GET /api/v1/posts/me
      routing.on 'me' do
        raise('No auth_token is given') if @auth_account.nil?

        posts = FindPostsForAccount.call(account_id: @auth_account['account_id'])
        JSON.pretty_generate(data: posts)
       rescue StandardError => e
        Api.logger.error(e.message)
        routing.halt 403, { message: e.message }.to_json
      end

      routing.on String do |post_id|
        # POST /api/v1/posts/[post_id]/votes
        routing.on 'votes' do
          raise('No auth_token is given') if @auth_account.nil?

          number = JSON.parse(routing.body.read)["number"].to_i
          vote = CreatePostVote.call(voter_username: @auth_account['username'], voted_post_id: post_id, number:)
          vote.to_json
        rescue StandardError => e
          Api.logger.error e.message
          routing.halt 500, { message: e.message }.to_json
        end

        # GET /api/v1/posts/[post_id]
        routing.get do
          FindSinglePostWithPolicies.call(post_id:, auth_account: @auth_account)
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET /api/v1/posts
      routing.get do
        all_posts = { data: Post.all }
        all_posts[:data] ? all_posts.to_json : raise('Could not find all posts')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end
    end
  end
end
