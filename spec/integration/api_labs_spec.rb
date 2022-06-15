# frozen_string_literal: true

require_relative '../spec_helper'
describe 'Test Lab Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database

    DATA[:schools].each do |school_data|
      Labook::School.create(school_data)
    end

    DATA[:departments].each do |dep_data|
      Labook::Department.create(dep_data)
    end
  end
  describe 'Getting Posts' do
    it 'Happy: should be able to get list of all labs' do
      Labook::Lab.create(DATA[:labs][0])
      Labook::Lab.create(DATA[:labs][1])

      get 'api/v1/labs'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result.count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single lab' do
      existing_lab = DATA[:labs][1]
      Labook::Lab.create(existing_lab)
      lab_id = Labook::Lab.first.lab_id

      get "/api/v1/labs/#{lab_id}"
      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body)['attributes']
      _(attributes['lab_id']).must_equal lab_id
      _(attributes['lab_name']).must_equal existing_lab['lab_name']
      _(attributes['school']).must_equal existing_lab['school_name']
      _(attributes['department']).must_equal existing_lab['department_name']
      _(attributes['professor']).must_equal existing_lab['professor']
    end

    it 'SAD: should return error if unknown lab requested' do
      get '/api/v1/labs/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Labook::School.create(school_name: 'Newer')
      Labook::Department.create(school_name: 'Newer', department_name: 'Newer')
      Labook::Lab.create(lab_name: 'Newer Lab', school: 'Newer', department: 'Newer', professor: 'Newer')
      get 'api/v1/labs/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Labs' do
    before do
      @lab_data = DATA[:labs][1]
    end

    it 'HAPPY: should be able to create new labs' do
      post 'api/v1/labs', @lab_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      lab = Labook::Lab.first

      _(created['lab_id']).must_equal lab.lab_id
      _(created['lab_name']).must_equal @lab_data['lab_name']
      _(created['school']).must_equal @lab_data['school_name']
      _(created['department']).must_equal @lab_data['department_name']
      _(created['professor']).must_equal @lab_data['professor']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @lab_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/labs', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
