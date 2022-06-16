# frozen_string_literal: true

require 'roda'
require_relative './app'

module Labook
  # Web controller for Labook API
  class Api < Roda
    route('labs') do |routing|
      @lab_route = "#{@api_root}/labs"

      routing.on String do |lab_id|
        routing.on 'posts' do
          @post_route = "#{@api_root}/labs/#{lab_id}/posts"

          # routing.on String do |post_id|
          #   routing.on 'votes' do
          #     # POST api/v1/labs/[lab_id]/posts/[post_id]/votes
          #     routing.post do
          #       new_data = JSON.parse(routing.body.read)
          #       new_vote = Labook::CreatePostVote.call(voter_username: new_data['voter_account'],
          #                                              voted_post_id: post_id,
          #                                              number: new_data['number'].to_i)
          #       raise('Could not save vote') unless new_vote

          #       response.status = 201
          #       response['Location'] = "#{@post_route}/#{new_vote.vote_id}"
          #       { message: 'Vote saved', data: new_vote }.to_json

          #     rescue Sequel::MassAssignmentRestriction
          #       Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          #       routing.halt 400, { message: 'Illegal Attributes' }.to_json
          #     rescue StandardError => e
          #       routing.halt 500, { message: e.message }.to_json
          #     end
          #   end

          #   # GET api/v1/labs/[lab_id]/posts/[post_id]
          #   routing.get do
          #     post = Post.where(lab_id:, post_id:).first
          #     post ? post.to_json : raise('Post not found')
          #   rescue StandardError => e
          #     routing.halt 404, { message: e.message }.to_json
          #   end
          # end

          # GET api/v1/labs/[lab_id]/posts
          routing.get do
            lab_posts = { data: FindPostsForLab.call(lab_id:) }
            lab_posts[:data] ? lab_posts.to_json : raise('Could not find all posts of the lab')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # POST api/v1/labs/[lab_id]/posts
          routing.post do
            raise('No auth_token is given or token is invalid.') if @auth_account.nil?

            post_data = JSON.parse(routing.body.read)
            new_post = CreatePost.call(poster_account: @auth_account['username'], lab_id:, post_data:)
            raise('Could not save post') unless new_post

            response.status = 201
            response['Location'] = "#{@post_route}/#{new_post.post_id}"
            { message: 'Post saved', data: new_post }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{post_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.warn e.inspect
            routing.halt 500, { message: e.message }.to_json
          end
        end
        # END -- api/v1/labs/[lab_id]/posts

        # GET api/v1/labs/[lab_id]
        routing.get do
          lab = Lab.first(lab_id:)
          lab ? lab.to_json : raise('Lab not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end
      # END -- api/v1/labs/[lab_id]

      # GET api/v1/labs
      routing.get do
        all_labs = FetchLabs.call
        all_labs ? all_labs.to_json : raise('Could not find all labs')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      # POST api/v1/labs
      routing.post do
        lab_data = JSON.parse(routing.body.read)
        new_lab = FindOrCreateLab.call(lab_data)

        response.status = 201
        response['Location'] = "#{@lab_route}/#{new_lab.lab_id}"
        { message: 'Lab found or saved', data: new_lab }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{lab_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "ERROR: #{e.message}"
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
