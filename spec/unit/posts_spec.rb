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
      post_info = post_data.clone
      account = post_info.delete('poster_account')
      lab_name = post_info.delete('lab_name')
      lab_id = Labook::Lab.first(lab_name:).lab_id

      new_post = Labook::CreatePost.call(
        poster_account: account,
        lab_id:,
        post_data: post_info
      )

      post = Labook::Post.find(post_id: new_post.post_id)
      _(post.lab_score.to_i).must_equal post_data['lab_score'].to_i
      _(post.professor_attitude).must_equal post_data['professor_attitude']
      _(post.content).must_equal post_data['content']
    end
  end
end
