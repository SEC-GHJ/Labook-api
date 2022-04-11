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
        { message: 'LabookAPI up at /api/v1' }.to_json
      end

      routing.on 'api/v1' do
        routing.on 'labs' do
          routing.on String do |lab_id|
            routing.on 'posts' do
              # GET api/v1/labs/[lab_id]/posts/[post_id]
              routing.get String do |post_id|
                find = PostObj.where(lab_id:, post_id:).first
                find ? find.to_json : raise('Post not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/labs/[lab_id]/posts
              routing.get do
                output = { data: LabObj.first(lab_id:).posts }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find all posts'
              end

              # POST api/v1/labs/[lab_id]/posts
              routing.post do
                new_data = JSON.parse(routing.body.read)
                lab = LabObj.first(lab_id:)
                new_post = lab.add_post(new_data) # NOT SURE!!! add_document() or add_post()

                if new_post
                  response.status = 201
                  response['Location'] = "api/v1/labs/#{lab_id}/posts/#{new_post.post_id}"
                  { message: 'Post saved', data: new_post }.to_json
                else
                  routing.halt 400, 'Could not save post'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/labs/[lab_id]
            routing.get do
              find = LabObj.first(lab_id:)
              find ? find.to_json : raise('Lab not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # GET api/v1/labs
            routing.get do
              output = { data: LabObj.all }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find all labs' }.to_json
            end

            # POST api/v1/labs
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_lab = LabObj.new(new_data)

              if new_lab.save
                response.status = 201
                response['Location'] = "api/v1/labs/#{new_lab.lab_id}"
                { message: 'Lab saved', data: new_lab }.to_json
              else
                routing.halt 400, { message: 'Could not save lab' }.to_json
              end
            rescue StandardError => e
              routing.halt 400, { message: e.message }.to_json
            end
          end
        end
      end
    end
  end
end
