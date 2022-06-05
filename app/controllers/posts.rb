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

        posts = FindPostsForAccount.call(account: @auth_account['account'])
        JSON.pretty_generate(data: posts)
       rescue StandardError => e
        routing.halt 403, { message: e.message }.to_json
      end

      routing.on String do |post_id|
        # GET /api/v1/posts/[post_id]
        routing.get do
          post = Post.where(post_id:).first
          raise('Post not found') if post.nil?
          

          requestor = @auth_account.nil? ? nil : Account.first(@auth_account['account'])

          # add policy in comments
          comments = post.clone.to_h[:include][:comments].map{ |comment|
            account = Account.first(account_id: comment[0].to_h[:attributes][:commenter_id])
            policy = AccountPolicy.new(requestor, account)

            [comment[0].to_h.merge(policies: policy.summary)]
          }

          # add policy in post
          account = Account.first(account_id: post.poster_id)
          policy = AccountPolicy.new(requestor, account)
          
          output = post.to_h.merge(policies: policy.summary)
          output[:include][:comments].replace(comments)
          output.to_json
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
