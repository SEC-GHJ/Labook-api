# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Post Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:labs].each do |lab_data|
      Labook::Lab.create(lab_data)
    end
  end

  it 'HAPPY: should be able to get list of all posts' do
    lab = Labook::Lab.first
    DATA[:posts].each do |post|
      lab.add_post(post)
    end

    get "api/v1/labs/#{lab.lab_id}/posts"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 4
  end

  it 'HAPPY: should be able to get details of a single post' do
    post_data = DATA[:posts][1]
    lab = Labook::Lab.first
    post = lab.add_post(post_data).save

    get "/api/v1/labs/#{lab.lab_id}/posts/#{post.post_id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['post_id']).must_equal post.post_id
    _(result['data']['attributes']['user_id']).must_equal post_data['user_id']
    _(result['data']['attributes']['lab_score'].to_i).must_equal post_data['lab_score'].to_i
    _(result['data']['attributes']['professor_attitude']).must_equal post_data['professor_attitude']
    _(result['data']['attributes']['content']).must_equal post_data['content']
  end

  it 'SAD: should return error if unknown post requested' do
    lab = Labook::Lab.first
    get "/api/v1/labs/#{lab.lab_id}/posts/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Posts' do
    before do
      @lab = Labook::Lab.first
      @post_data = DATA[:posts][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new posts' do
      post "api/v1/labs/#{@lab.lab_id}/posts",
          @post_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      post = Labook::Post.first

      _(created['post_id']).must_equal post.post_id
      _(created['user_id']).must_equal @post_data['user_id']
      _(created['lab_score'].to_i).must_equal @post_data['lab_score'].to_i
      _(created['professor_attitude']).must_equal @post_data['professor_attitude']
      _(created['content']).must_equal @post_data['content']
    end

    it 'SECURITY: should not create posts with mass assignment' do
      bad_data = @post_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/labs/#{@lab.lab_id}/posts",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
