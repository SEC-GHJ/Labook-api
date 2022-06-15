# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
def wipe_database
  Labook::CommentVote.map(&:destroy)
  Labook::AccountsComment.map(&:destroy)
  Labook::Comment.map(&:destroy)
  Labook::AccountsCommentPost.map(&:destroy)
  Labook::PostVote.map(&:destroy)
  Labook::AccountsPost.map(&:destroy)
  Labook::Post.map(&:destroy)
  Labook::AccountsLab.map(&:destroy)
  Labook::Chat.map(&:destroy)
  Labook::AccountsAccount.map(&:destroy)
  Labook::Lab.map(&:destroy)
  Labook::Account.map(&:destroy)
  Labook::School.map(&:destroy)
  Labook::Department.map(&:destroy)
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity

def authenticate(account_data)
  credentials = {
    username: account_data['username'],
    password: account_data['password']
  }
  Labook::AuthenticateAccount.call(credentials)
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {}  # rubocop:disable Style/MutableConstant
DATA[:posts] = YAML.safe_load File.read('app/db/seeds/posts_seed.yml')
DATA[:labs] = YAML.safe_load File.read('app/db/seeds/labs_seed.yml')
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:chats] = YAML.safe_load File.read('app/db/seeds/chats_seed.yml')
DATA[:schools] = YAML.safe_load File.read('app/db/seeds/schools_seed.yml')
DATA[:departments] = YAML.safe_load File.read('app/db/seeds/departments_seed.yml')
