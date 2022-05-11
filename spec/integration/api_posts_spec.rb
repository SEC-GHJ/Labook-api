# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Post Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:labs].each do |lab_data|
      Labook::Lab.create(lab_data)
    end

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end
  end

  it 'HAPPY: should be able to get list of all posts' do
    DATA[:posts].each do |post_data|
      post_info = post_data.clone
      poster_account = post_info.delete('poster_account')
      lab_name = post_info.delete('lab_name')
      lab_id = Labook::Lab.first(lab_name:).lab_id
      Labook::CreatePost.call(poster_account:, lab_id:, post_data: post_info)
    end

    # puts "Post: #{Labook::Post.all}"
    lab = Labook::Lab.first(lab_name: DATA[:posts][0]['lab_name'])
    get "api/v1/labs/#{lab.lab_id}/posts"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single post' do
    post_data = DATA[:posts][0]
    post_info = post_data.clone
    account = post_info.delete('poster_account')
    lab_name = post_info.delete('lab_name')
    poster_id = Labook::Account.first(account:).account_id
    lab_id = Labook::Lab.first(lab_name:).lab_id
    new_post = Labook::CreatePost.call(poster_account: account, lab_id:, post_data: post_info)

    get "/api/v1/labs/#{new_post.lab_id}/posts/#{new_post.post_id}"
    _(last_response.status).must_equal 200

    attributes = JSON.parse(last_response.body)['attributes']
    _(attributes['post_id']).must_equal new_post.post_id
    _(attributes['poster_id']).must_equal poster_id
    _(attributes['lab_score'].to_i).must_equal post_data['lab_score'].to_i
    _(attributes['professor_attitude']).must_equal post_data['professor_attitude']
    _(attributes['content']).must_equal post_data['content']
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

    # it 'HAPPY: should be able to create new posts' do
    #   post "api/v1/labs/#{@lab.lab_id}/posts",
    #        @post_data.to_json, @req_header
    #   _(last_response.status).must_equal 201
    #   _(last_response.header['Location'].size).must_be :>, 0

    #   created = JSON.parse(last_response.body)['data']['data']['attributes']
    #   post = Labook::Post.first

    #   _(created['post_id']).must_equal post.post_id
    #   _(created['poster_id']).must_equal @post_data['poster_id']
    #   _(created['lab_score'].to_i).must_equal @post_data['lab_score'].to_i
    #   _(created['professor_attitude']).must_equal @post_data['professor_attitude']
    #   _(created['content']).must_equal @post_data['content']
    # end

    # it 'SECURITY: should not create posts with mass assignment' do
    #   bad_data = @post_data.clone
    #   bad_data['created_at'] = '1900-01-01'
    #   post "api/v1/labs/#{@lab.lab_id}/posts",
    #        bad_data.to_json, @req_header

    #   _(last_response.status).must_equal 400
    #   _(last_response.header['Location']).must_be_nil
    # end
  end
end
