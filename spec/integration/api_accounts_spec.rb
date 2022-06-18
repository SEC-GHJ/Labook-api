# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Account & Account Connection' do
    before do
      # user 1 open accept_mail & show_all
      @user1_data = DATA[:accounts][0]
      @open_account = Labook::Account.create(@user1_data)

      @user2_data = DATA[:accounts][1]
      @user2_account = Labook::Account.create(@user2_data)

      @user3_data = DATA[:accounts][2]
      @private_account = Labook::Account.create(@user3_data)
    end

    describe 'Getting other account profile' do
      it 'HAPPY: should be able to get details of an open account' do
        
        header 'AUTHORIZATION', auth_header(@user2_data)
        get "/api/v1/accounts/#{@open_account.account_id}"
        _(last_response.status).must_equal 200
  
        attributes = JSON.parse(last_response.body)['attributes']
        _(attributes['username']).must_equal @open_account.username
        _(attributes['nickname']).must_equal @open_account.nickname
        _(attributes['gpa']).must_equal @open_account.gpa
        _(attributes['email']).must_equal @open_account.email
        _(attributes['ori_school']).must_equal @open_account.ori_school
        _(attributes['ori_department']).must_equal @open_account.ori_department
        _(attributes['accept_mail']).must_equal @open_account.accept_mail
        _(attributes['show_all']).must_equal @open_account.show_all
        _(attributes['can_notify']).must_equal false
        _(attributes['salt']).must_be_nil
        _(attributes['password']).must_be_nil
        _(attributes['password_hash']).must_be_nil
      end
  
      it 'BAD: should not be able to see other private account' do
        header 'AUTHORIZATION', auth_header(@user2_data)
        get "/api/v1/accounts/#{@private_account.account_id}"
  
        _(last_response.status).must_equal 404
      end
    end

    describe 'Creating new chatroom with other account' do
      it 'HAPPY: should be able to create chatroom with other account' do
        header 'AUTHORIZATION', auth_header(@user2_data)
        post "/api/v1/accounts/#{@open_account.account_id}/contact"

        _(last_response.status).must_equal 200

        attributes = JSON.parse(last_response.body)['attributes']
        type = JSON.parse(last_response.body)['type']

        _(attributes['sender_id']).must_equal @user2_account.account_id
        _(attributes['receiver_id']).must_equal @open_account.account_id
        _(type).must_equal 'chatroom'
      end

      it 'BAD PREVENT_ACTION: should be not able to create chatroom with itself' do
        header 'AUTHORIZATION', auth_header(@user2_data)
        post "/api/v1/accounts/#{@user2_account.account_id}/contact"

        _(last_response.status).must_equal 404
      end
    end
  end

  describe 'Account Creation' do
    before do
      @account_data = DATA[:accounts][2]
      @account_data['ori_department'] = Base64.strict_encode64(@account_data['ori_department'])
      @account_data['ori_school'] = Base64.strict_encode64(@account_data['ori_school'])
      @account_data['nickname'] = Base64.strict_encode64(@account_data['nickname'])
    end

    it 'HAPPY: should be able to create new accounts' do
      # puts "@account: #{SignedRequest.new(app.config).sign(@account_data).to_json}"
      post 'api/v1/accounts',
           SignedRequest.new(app.config).sign(@account_data).to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = Labook::Account.first

      _(created['username']).must_equal @account_data['username']
      _(created['nickname']).must_equal Base64.strict_decode64(@account_data['nickname'])
      _(created['gpa']).must_equal @account_data['gpa']
      _(created['email']).must_equal @account_data['email']
      _(created['ori_school']).must_equal Base64.strict_decode64(@account_data['ori_school'])
      _(created['ori_department']).must_equal Base64.strict_decode64(@account_data['ori_department'])
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD MASS_ASSIGNMENT: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts',
           SignedRequest.new(app.config).sign(bad_data).to_json,
           @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end

  describe 'Update (PATCH) Account Setting' do
    before do
      # user 1 open accept_mail & show_all
      @user1_data = DATA[:accounts][0]
      @open_account = Labook::Account.create(@user1_data)
      @new_setting = {
        accept_mail: 0,
        show_all: 0
      }
    end

    it 'HAPPY: update the setting' do
      header 'AUTHORIZATION', auth_header(@user1_data)
      patch "/api/v1/accounts/setting", @new_setting.to_json
      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body)['attributes']
      _(attributes['username']).must_equal @open_account.username
      _(attributes['nickname']).must_equal @open_account.nickname
      _(attributes['gpa']).must_equal @open_account.gpa
      _(attributes['email']).must_equal @open_account.email
      _(attributes['ori_school']).must_equal @open_account.ori_school
      _(attributes['ori_department']).must_equal @open_account.ori_department
      _(attributes['show_all']).must_equal @new_setting[:show_all]
      _(attributes['accept_mail']).must_equal @new_setting[:accept_mail]
    end

    it 'HAPPY: update the setting but setting remain same' do
      same_setting = {
        accept_mail: 1,
        show_all: 1
      }
      header 'AUTHORIZATION', auth_header(@user1_data)
      patch "/api/v1/accounts/setting", same_setting.to_json
      _(last_response.status).must_equal 204
    end

    it 'SAD AUTHORIZATION: should not process without authorization' do
      patch "/api/v1/accounts/setting", @new_setting.to_json
      _(last_response.status).must_equal 403
    end
  end
end
