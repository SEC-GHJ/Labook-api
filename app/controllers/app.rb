# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/post'

module Labook
  # Web controller for Labook API
  class Api < Roda
    plugin :environments
    plugin :halt

    # configure data store
    configure do
      Post.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'LabookAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'posts' do
            # GET api/v1/posts/[post_id]
            routing.get String do |post_id|
              response.status = 200
              Post.find(post_id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Post not found' }.to_json
            end

            # GET api/v1/posts
            routing.get do
              response.status = 200
              output = { post_ids: Post.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/posts
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_post = Post.new(new_data)

              if new_post.save
                response.status = 201
                { message: 'Post saved', id: new_post.post_id }.to_json
              else
                routing.halt 400, { message: 'Could not save post' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
