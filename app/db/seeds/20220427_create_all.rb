# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, schools, departments, labs'
    create_accounts
    create_schools
    create_departments
    create_labs
    puts 'Seeding posts, chatrooms, chats'
    posts = create_posts
    # puts posts
    create_chatrooms
    create_chats
    puts 'Seeding votes, comments'
    create_post_votes(posts)
    create_comments(posts)
    create_comment_votes
    puts 'Seeding NTHUs'
    create_NTHU
  end
end

require 'yaml'
# DIR = 'app/db/seeds'
DIR = File.dirname(__FILE__)
NTHU_INFO = YAML.load_file("#{DIR}/NTHUdepartment.yml")
SCHOOLS_INFO = YAML.load_file("#{DIR}/schools_seed.yml")
DEPARTMENTS_INFO = YAML.load_file("#{DIR}/departments_seed.yml")
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CHATS_INFO = YAML.load_file("#{DIR}/chats_seed.yml")
LABS_INFO = YAML.load_file("#{DIR}/labs_seed.yml")
POSTS_INFO = YAML.load_file("#{DIR}/posts_seed.yml")
POSTVOTES_INFO = YAML.load_file("#{DIR}/post_votes_seed.yml")
COMMENTS_INFO = YAML.load_file("#{DIR}/comments_seed.yml")
COMMENTVOTES_INFO = YAML.load_file("#{DIR}/comment_votes_seed.yml")
POSTS = nil

def create_NTHU
  NTHU_INFO.each do |nthu_info|
    Labook::School.first(school_name: "NTHU").add_department(department_name: nthu_info['department'])
    
    department = Labook::Department.first(school_name: "NTHU", department_name: nthu_info['department'])
    nthu_info['profs'].each do |profs|
      department.add_lab(professor: profs)
    end
  end
end

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Labook::Account.create(account_info)
  end
end

def create_schools
  SCHOOLS_INFO.each do |school_info|
    Labook::School.create(school_info)
  end
end

def create_departments
  DEPARTMENTS_INFO.each do |department_info|
    school_name = department_info.delete('school_name')
    Labook::School.first(school_name:).add_department(department_info)
  end
end

def create_labs
  LABS_INFO.each do |lab_info|
    school_name = lab_info.delete('school')
    department_name = lab_info.delete('department')
    Labook::Department.first(school_name:, department_name:).add_lab(lab_info)
  end
end

# rubocop:disable Metrics/MethodLength
def create_posts
  POSTS_INFO.collect do |post_data|
    post_info = post_data.clone
    poster_account = post_info.delete('poster_account')
    lab_name = post_info.delete('lab_name')
    lab_id = Labook::Lab.first(lab_name:).lab_id

    Labook::CreatePost.call(
      poster_account:,
      lab_id:,
      post_data: post_info
    ).post_id
  end
end

# rubocop:enable Metrics/MethodLength
def create_chatrooms
  CHATS_INFO.each do |chat_data|
    Labook::FindOrCreateChatroom.call(
      sender_account: chat_data['sender_account'],
      receiver_account: chat_data['receiver_account']
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

def create_post_votes(posts)
  POSTVOTES_INFO.each do |vote_data|
    Labook::CreatePostVote.call(
      voter_username: vote_data['voter'],
      voted_post_id: posts[vote_data['voted_post_id'].to_i - 1],
      number: vote_data['number']
    )
  end
end

def create_comments(posts)
  COMMENTS_INFO.each do |comment_data|
    comment_info = comment_data.clone
    commenter_account = comment_info.delete('commenter_account')
    commented_post_id = posts[comment_info.delete('commented_post_id').to_i - 1]

    Labook::CreateComment.call(
      commenter_account:,
      commented_post_id:,
      comment_data: comment_info
    )
  end
end

def create_comment_votes
  COMMENTVOTES_INFO.each do |vote_data|
    Labook::CreateCommentVote.call(
      voter_account: vote_data['voter'],
      voted_comment_id: vote_data['voted_comment_id'],
      number: vote_data['number']
    )
  end
end
