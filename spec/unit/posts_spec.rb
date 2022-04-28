# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Post Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end

    DATA[:labs].each do |lab_data|
      Labook::Lab.create(lab_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    DATA[:posts].each do |post_data|
      poster = Labook::Account.find(account: post_data['poster_account'])
      lab = Labook::Lab.find(lab_name: post_data['lab_name'])

      new_post = Labook::CreatePost.call(
        poster_id: poster.account_id,
        lab_id: lab.lab_id,
        post_data: post_data
      )

      post = Labook::Post.find(post_id: new_post.post_id)
      _(post.lab_score.to_i).must_equal post_data['lab_score'].to_i
      _(post.professor_attitude).must_equal post_data['professor_attitude']
      _(post.content).must_equal post_data['content']
    end
  end

  it 'SECURITY: should secure sensitive attributes' do
    DATA[:posts].each do |post_data|
      poster = Labook::Account.find(account: post_data['poster_account'])
      lab = Labook::Lab.find(lab_name: post_data['lab_name'])

      new_post = Labook::CreatePost.call(
        poster_id: poster.account_id,
        lab_id: lab.lab_id,
        post_data: post_data
      )

      stored_post = Labook::Post.find(post_id: new_post.post_id)
      _(stored_post[:lab_score_secure]).wont_equal new_post.lab_score
      _(stored_post[:professor_attitude_secure]).wont_equal new_post.professor_attitude
      _(stored_post[:content_secure]).wont_equal new_post.content
    end
  end
end
