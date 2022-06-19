# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Post Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    DATA[:schools].each do |school_data|
      Labook::School.create(school_data)
    end

    DATA[:departments].each do |dep_data|
      Labook::Department.create(dep_data)
    end

    DATA[:labs].each do |lab_data|
      Labook::Lab.create(lab_data)
    end

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end

    # Create posts
    DATA[:posts].each do |post_data|
      post_info = post_data.clone
      poster_account = post_info.delete('poster_account')
      lab_name = post_info.delete('lab_name')
      lab_id = Labook::Lab.first(lab_name:).lab_id
      Labook::CreatePost.call(poster_account:, lab_id:, post_data: post_info)
    end

    @user_data = DATA[:accounts][0]
    @post_id = Labook::Post.first.post_id
  end

  describe 'Getting all posts' do
    it 'HAPPY: should be able to get list of all posts' do
      get "api/v1/posts"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 12
    end
  end

  describe 'Getting post for a specific user' do
    it 'HAPPY: should be able to get posts for a specific user' do
      header 'AUTHORIZATION', auth_header(@user_data)
      get "/api/v1/posts/me"
      poster_id = Labook::Account.first(username: @user_data['username']).account_id

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      single_post = result['data'][0]['attributes']

      _(result['data'].count).must_equal 6
      result['data'].each do |single_post|
        attributes = single_post['attributes']
        _(single_post['type']).must_equal 'post'
      end
    end

    it 'SAD AUTHORIZATION: should not be able to get posts for a specific user' do
      get "/api/v1/posts/me"
      _(last_response.status).must_equal 403
    end
  end

  describe 'Creating other property for a specific post' do
    describe 'Creating a vote for a specific post' do
      before do
        @vote = { number: 2 }
      end
      it 'HAPPY: should be able to create a vote' do
        header 'AUTHORIZATION', auth_header(@user_data)
        post "/api/v1/posts/#{@post_id}/votes", @vote.to_json
        _(last_response.status).must_equal 200
  
        result = JSON.parse(last_response.body)['attributes']
        _(result['number']).must_equal @vote[:number]
        _(result['vote_id']).wont_be_nil
      end
  
      it 'SAD AUTHORIZATION: should not be able to create a vote' do
        post "/api/v1/posts/#{@post_id}/votes", @vote.to_json
        _(last_response.status).must_equal 403
      end

      it 'SAD: should not be able to create a vote due to missing para' do
        header 'AUTHORIZATION', auth_header(@user_data)
        post "/api/v1/posts/#{@post_id}/votes"
        _(last_response.status).must_equal 500
      end
    end

    describe 'Creating a comment for a specific post' do
      before do
        @comment = {
          content: 'Hello it is a test',
          vote_sum: 0
        }
      end

      it 'HAPPY: should be able to create a comment' do
        header 'AUTHORIZATION', auth_header(@user_data)
        post "/api/v1/posts/#{@post_id}/comments", @comment.to_json
        _(last_response.status).must_equal 200
  
        result = JSON.parse(last_response.body)['attributes']
        _(result['content']).must_equal @comment[:content]
        _(result['vote_sum']).must_equal @comment[:vote_sum]
        _(result['comment_id']).wont_be_nil
        _(result['commenter_id']).wont_be_nil
        _(result['commented_post_id']).wont_be_nil
      end

      it 'SAD: should not be able to create a comment due to missing para' do
        header 'AUTHORIZATION', auth_header(@user_data)
        post "/api/v1/posts/#{@post_id}/comments"
        _(last_response.status).must_equal 500
      end

      it 'BAD MASS_ASSIGNMENT: should not create a comment with mass assignment' do
        @comment[:created_at] = '1988-8-8'
        header 'AUTHORIZATION', auth_header(@user_data)
        post "/api/v1/posts/#{@post_id}/comments", @comment.to_json
        _(last_response.status).must_equal 400
      end
    end
  end

  describe 'Getting a specific post' do
    it 'HAPPY: should be able to get a post' do
      post_data = DATA[:posts][0]
      header 'AUTHORIZATION', auth_header(@user_data)
      get "/api/v1/posts/#{@post_id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['attributes']
      _(result['lab_score']).must_equal post_data['lab_score']
      _(result['professor_attitude']).must_equal post_data['professor_attitude']
      _(result['content']).must_equal post_data['content']
      _(result['vote_sum']).must_equal post_data['vote_sum']
      _(result['post_id']).wont_be_nil
      _(result['lab_id']).wont_be_nil
      _(result['poster_id']).wont_be_nil
    end

    it 'SAD: should return error if unknown post requested' do
      post_data = DATA[:posts][0]
      header 'AUTHORIZATION', auth_header(@user_data)
      get "/api/v1/posts/123214"
      _(last_response.status).must_equal 404
    end
  end
end
