# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:posts].delete
  app.DB[:labs].delete
end

DATA = {}  # rubocop:disable Style/MutableConstant
DATA[:posts] = YAML.safe_load File.read('app/db/seeds/post_seeds.yml')
DATA[:labs] = YAML.safe_load File.read('app/db/seeds/lab_seeds.yml')
