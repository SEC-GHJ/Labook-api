# frozen_string_literal: true

require_relative './spec_helper'
describe 'Test Lab Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end
  it 'Happy: should be able to get list of all labs' do
    Labook::Lab.create(DATA[:labs][0]).save
    Labook::Lab.create(DATA[:labs][1]).save
    Labook::Lab.create(DATA[:labs][2]).save
    Labook::Lab.create(DATA[:labs][3]).save

    get 'api/v1/labs'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 4
  end

  it 'HAPPY: should be able to get details of a single lab' do
    existing_lab = DATA[:labs][1]
    Labook::Lab.create(existing_lab).save
    lab_id = Labook::Lab.first.lab_id

    get "/api/v1/labs/#{lab_id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['lab_id']).must_equal lab_id
    _(result['data']['attributes']['lab_name']).must_equal existing_lab['lab_name']
    _(result['data']['attributes']['school']).must_equal existing_lab['school']
    _(result['data']['attributes']['department']).must_equal existing_lab['department']
    _(result['data']['attributes']['professor']).must_equal existing_lab['professor']
  end

  it 'SAD: should return error if unknown lab requested' do
    get '/api/v1/labs/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new labs' do
    existing_lab = DATA[:labs][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/labs', existing_lab.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    lab = Labook::Lab.first

    _(created['lab_id']).must_equal lab.lab_id
    _(created['lab_name']).must_equal existing_lab['lab_name']
    _(created['school']).must_equal existing_lab['school']
    _(created['department']).must_equal existing_lab['department']
    _(created['professor']).must_equal existing_lab['professor']
  end
end
