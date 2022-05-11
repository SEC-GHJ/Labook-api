# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, documents'
    create_accounts
    create_labs
    create_posts
    create_chats
    create_votes
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CHATS_INFO = YAML.load_file("#{DIR}/chats_seed.yml")
LABS_INFO = YAML.load_file("#{DIR}/labs_seed.yml")
POSTS_INFO = YAML.load_file("#{DIR}/posts_seed.yml")
VOTES_INFO = YAML.load_file("#{DIR}/votes_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Labook::Account.create(account_info)
  end
end

def create_labs
  LABS_INFO.each do |lab_info|
    Labook::Lab.create(lab_info)
  end
end

# rubocop:disable Metrics/MethodLength
def create_posts
  POSTS_INFO.each do |post_data|
    post_info = post_data.clone
    poster_account = post_info.delete('poster_account')
    lab_name = post_info.delete('lab_name')
    lab_id = Labook::Lab.first(lab_name:).lab_id

    Labook::CreatePost.call(
      poster_account:,
      lab_id:,
      post_data: post_info
    )
  end
end

# rubocop:enable Metrics/MethodLength
def create_chats
  CHATS_INFO.each do |chat_data|
    Labook::CreateChat.call(
      sender_account: chat_data['sender_account'],
      receiver_account: chat_data['receiver_account'],
      content: chat_data['content']
    )
  end
end

def create_votes
  VOTES_INFO.each do |vote_data|
    Labook::CreateVote.call(
      voter_account: vote_data['voter'],
      voted_post_id: vote_data['voted_post_id'],
      number: vote_data['number']
    )
  end
end
