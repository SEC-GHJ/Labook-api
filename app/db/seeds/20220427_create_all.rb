# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, documents'
    create_accounts
    create_labs
    # create_posts
    # create_chats
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CHATS_INFO = YAML.load_file("#{DIR}/chats_seed.yml")
LABS_INFO = YAML.load_file("#{DIR}/labs_seed.yml")
POSTS_INFO = YAML.load_file("#{DIR}/posts_seed.yml")


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

def create_posts
  POSTS_INFO.each do |post|
    poster = Labook::Account.first(account: post['poster_account'])
    lab = Labook::Lab.first(lab_name: post['lab_name'])
    Labook::CreatePost.call(                  # service func. name & I/O
      poster_id: poster.account_id,
      lab_id: lab.lab_id,
      post_data: post
    )
  end
end

def create_chats
  CHATS_INFO.each do |chat|
    sender = Labook::Account.first(account: chat['poster_account'])
    receiver = Labook::Account.first(account: chat['poster_account'])
    Labook::CreateChat.call(                  # service func. name & I/O
      sender_id: sender.account_id,
      receiver_id: receiver.account_id,
      content: chat['content']
    )
  end
end
