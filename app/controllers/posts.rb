# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('posts') do |routing|
      @account_route = "#{@api_root}/posts"

      routing.get do
        all_posts = { data: Post.all }
        all_posts[:data] ? all_posts.to_json : raise('Could not find all posts')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end
    end
  end
end
