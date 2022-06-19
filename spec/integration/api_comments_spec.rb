# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Chat Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end

    DATA[:schools].each do |school_data|
      Labook::School.create(school_data)
    end

    DATA[:departments].each do |dep_data|
      Labook::Department.create(dep_data)
    end

    DATA[:labs].each do |lab_data|
      Labook::Lab.create(lab_data)
    end

    # Create posts
    posts = DATA[:posts].collect do |post_data|
      post_info = post_data.clone
      poster_account = post_info.delete('poster_account')
      lab_name = post_info.delete('lab_name')
      lab_id = Labook::Lab.first(lab_name:).lab_id
      Labook::CreatePost.call(poster_account:, lab_id:, post_data: post_info)
    end

    DATA[:comments].each do |comment_data|
      comment_info = comment_data.clone
      commenter_account = comment_info.delete('commenter_account')
      commented_post_id = posts[comment_info.delete('commented_post_id')].post_id
  
      Labook::CreateComment.call(
        commenter_account:,
        commented_post_id:,
        comment_data: comment_info
      )
    end

    @user_data = DATA[:accounts][0]
    @comment_id = Labook::Comment.first.comment_id
  end

  describe 'Creating a new votes to comment' do
    before do
      @vote_data = {
        number: 2
      }
    end

    it 'HAPPY: should be able to create a new vote' do
      header 'AUTHORIZATION', auth_header(@user_data)
      post "/api/v1/comments/#{@comment_id}/votes", @vote_data.to_json

      _(last_response.status).must_equal 200
      attributes = JSON.parse(last_response.body)['attributes']
      _(attributes['number']).must_equal @vote_data[:number]
      _(attributes['vote_id']).wont_be_nil
    end

    it 'SAD: should not process without params number' do
      header 'AUTHORIZATION', auth_header(@user_data)
      post "/api/v1/comments/#{@comment_id}/votes"

      _(last_response.status).must_equal 500
    end

    it 'SAD AUTHORIZATION: should not process without authorization' do
      post "/api/v1/comments/#{@comment_id}/votes", @vote_data.to_json

      _(last_response.status).must_equal 403
    end
  end
end
