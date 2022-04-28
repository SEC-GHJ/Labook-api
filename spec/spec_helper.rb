# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:labs].delete
  app.DB[:accounts].delete
  app.DB[:chats].delete
  app.DB[:posts].delete
end

DATA = {}  # rubocop:disable Style/MutableConstant
DATA[:posts] = YAML.safe_load File.read('app/db/seeds/posts_seed.yml')
DATA[:labs] = YAML.safe_load File.read('app/db/seeds/labs_seed.yml')
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:chats] = YAML.safe_load File.read('app/db/seeds/chats_seed.yml')