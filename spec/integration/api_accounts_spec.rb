# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of an open account' do
      # user 1 open accept_mail & show_all
      user1_data = DATA[:accounts][0]
      first_account = Labook::Account.create(user1_data)

      user2_data = DATA[:accounts][1]
      Labook::Account.create(user2_data)

      header 'AUTHORIZATION', auth_header(user2_data)
      get "/api/v1/accounts/#{first_account.account_id}"
      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body)['attributes']
      _(attributes['username']).must_equal first_account.username
      _(attributes['nickname']).must_equal first_account.nickname
      _(attributes['gpa']).must_equal first_account.gpa
      _(attributes['ori_school']).must_equal first_account.ori_school
      _(attributes['ori_department']).must_equal first_account.ori_department
      _(attributes['salt']).must_be_nil
      _(attributes['password']).must_be_nil
      _(attributes['password_hash']).must_be_nil
    end
  end

  describe 'Account Creation' do
    before do
      @account_data = DATA[:accounts][1]
      @account_data['username'] = Base64.strict_encode64(@account_data['username'])
      @account_data['ori_department'] = Base64.strict_encode64(@account_data['ori_department'])
      @account_data['nickname'] = Base64.strict_encode64(@account_data['nickname'])
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/accounts',
           SignedRequest.new(app.config).sign(@account_data).to_json,
           @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = Labook::Account.first

      _(created['username']).must_equal @account_data['username']
      _(created['nickname']).must_equal @account_data['nickname']
      _(created['gpa']).must_equal @account_data['gpa']
      _(created['ori_school']).must_equal @account_data['ori_school']
      _(created['ori_department']).must_equal @account_data['ori_department']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts',
           SignedRequest.new(app.config).sign(bad_data).to_json,
           @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
