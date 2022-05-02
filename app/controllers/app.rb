# frozen_string_literal: true

require 'roda'
require 'json'

module Labook
  # Web controller for Labook API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        Api.logger.debug 'Testing LabookAPI at /api/v1'
        Api.logger.info 'Testing LabookAPI at /api/v1'
        Api.logger.warn 'Testing LabookAPI at /api/v1'
        Api.logger.error 'Testing LabookAPI at /api/v1'
        { message: 'LabookAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'

      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(account: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # POSt api/v1/accounts/[username]
            routin.post do
              new_data = JSON.parse(routing.body.read)
              new_account = Account.new(new_data)
              raise('Could not save account') unless new_account.save
  
              response.status = 201
              response['Location'] = "#{@account_route}/#{new_account.account_id}"
              { message: 'Account created', data: new_account }.to_json
            rescue Sequel::MassAssignmentRestriction
              Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
              routing.halt 400, { message: 'Illegal Request' }.to_json
            rescue StandardError => e
              Api.logger.error 'Unknown error saving account'
              routing.halt 500, { message: e.message }.to_json
            end
          end
        end



        routing.on 'labs' do
          @lab_route = "#{@api_root}/labs"

          routing.on String do |lab_id|
            routing.on 'posts' do
              @post_route = "#{@api_root}/labs/#{lab_id}/posts"

              # GET api/v1/labs/[lab_id]/posts/[post_id]
              routing.get String do |post_id|
                find = Post.where(lab_id:, post_id:).first
                find ? find.to_json : raise('Post not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/labs/[lab_id]/posts
              routing.get do
                output = { data: FindPostsForLab.call(lab_id:) }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, 'Could not find all posts'
              end

              # POST api/v1/labs/[lab_id]/posts
              routing.post do
                new_data = JSON.parse(routing.body.read)
                # Labook::CreatePost.call(new_data)

                if new_post
                  response.status = 201
                  response['Location'] = "#{@post_route}/#{new_post.post_id}"
                  { message: 'Post saved', data: new_post }.to_json
                else
                  routing.halt 400, 'Could not save post'
                end
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end
            # END -- api/v1/labs/[lab_id]/posts

            # GET api/v1/labs/[lab_id]
            routing.get do
              find = Lab.first(lab_id:)
              find ? find.to_json : raise('Lab not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end
          # END -- api/v1/labs/[lab_id]

          # GET api/v1/labs
          routing.get do
            output = { data: Lab.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find all labs' }.to_json
          end

          # POST api/v1/labs
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_lab = Lab.new(new_data)

            if new_lab.save
              response.status = 201
              response['Location'] = "#{@lab_route}/#{new_lab.lab_id}"
              { message: 'Lab saved', data: new_lab }.to_json
            else
              routing.halt 500, { message: 'Could not save lab' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
