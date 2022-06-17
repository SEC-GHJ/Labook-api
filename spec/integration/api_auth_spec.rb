# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = Labook::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { username: @account_data['username'],
                      password: @account_data['password'] }
      post 'api/v1/auth/authenticate',
           SignedRequest.new(app.config).sign(credentials).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['attributes']['account']['attributes']
      _(last_response.status).must_equal 200
      _(auth_account['username']).must_equal(@account_data['username'])
      _(auth_account['nickname']).must_equal(@account_data['nickname'])
      _(auth_account['password']).must_be_nil
      _(auth_account['gpa']).must_equal(@account_data['gpa'])
      _(auth_account['ori_school']).must_equal(@account_data['ori_school'])
      _(auth_account['ori_department']).must_equal(@account_data['ori_department'])
      _(auth_account['account_id']).wont_be_nil
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { username: @account_data['username'],
                      password: 'fakepassword' }

      
      post 'api/v1/auth/authenticate',
            SignedRequest.new(app.config).sign(credentials).to_json,
            @req_header

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end
end
