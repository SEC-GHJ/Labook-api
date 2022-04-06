# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/postobj'

def app
  Labook::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/post_seeds.yml')

describe 'Test Labook Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{Labook::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle posts' do
    it 'HAPPY: should be able to get list of all posts' do
      Labook::PostObj.new(DATA[0]).save
      Labook::PostObj.new(DATA[1]).save

      get 'api/v1/posts'
      result = JSON.parse last_response.body

      _(result['post_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single post' do
      Labook::PostObj.new(DATA[1]).save
      id = Dir.glob("#{Labook::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/posts/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['post_id']).must_equal id
    end

    it 'SAD: should return error if unknown post requested' do
      get '/api/v1/posts/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new posts' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/posts', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
