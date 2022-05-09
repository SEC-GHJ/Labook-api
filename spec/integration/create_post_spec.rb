# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test User Create Post service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Labook::Account.create(account_data)
    end

    DATA[:labs].each do |lab_data|
      Labook::Lab.create(lab_data)
    end

    @poster = Labook::Account.all[0]
    @lab = Labook::Lab.all[0]
    @post_data = DATA[:posts][0].clone
    @post_data.delete('lab_name')
    @post_data.delete('poster_account')
  end

  it 'HAPPY: should be able to add a post according to lab' do
    Labook::CreatePost.call(
      poster_id: @poster.account_id,
      lab_id: @lab.lab_id,
      post_data: @post_data
    )

    _(@poster.owned_posts.count).must_equal 1
    _(@poster.owned_posts.first).must_equal @lab
  end

  it 'BAD: should not add a post according to non existent lab' do
    _(proc {
        Labook::CreatePost.call(
          poster_id: @poster.account_id,
          lab_id: '3069324',
          post_data: @post_data
        )
      }).must_raise Labook::CreatePost::LabNotFoundError
  end

  it 'BAD: should not add a post according to non account' do
    _(proc {
        Labook::CreatePost.call(
          poster_id: '30678',
          lab_id: @lab.lab_id,
          post_data: @post_data
        )
      }).must_raise Labook::CreatePost::PosterNotFoundError
  end
end
