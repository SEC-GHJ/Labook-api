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
        posts = FindPostsForAccount.call(account: @auth_account['account'])
        JSON.pretty_generate(data: posts)
      rescue StandardError
        routing.halt 403, { message: 'Can not find projects' }.to_json
      end

      routing.on String do |post_id|
        # GET /api/v1/posts/[post_id]
        routing.get do
          post = Post.where(post_id:).first
          post ? post.to_json : raise('Post not found')
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
