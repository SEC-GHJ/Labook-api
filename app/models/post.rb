# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Labook
  STORE_DIR = 'app/db/store'

  # Holds a full secret document
  class Post
    # Create a new post by passing in hash of attributes
    def initialize(new_post)
      @post_id = new_post['post_id'] || new_id
      @gpa = new_post['gpa']
      @ori_school = new_post['ori_school']
      @ori_department = new_post['ori_department']
      @school_department = new_post['school_department']
      @lab_score = new_post['lab_score']
      @professor_attitude = new_post['professor_attitude']
      @content = new_post['content']
    end

    attr_reader :post_id, :gpa, :ori_school, :ori_department, :school_department, :lab_score, :professor_attitude, :content

    def to_json(options = {})
      JSON({ type: 'post', post_id:, gpa:, ori_school:, ori_department:,
             school_department:, lab_score:, professor_attitude:, content: }, options)
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(Labook::STORE_DIR) unless Dir.exist? Labook::STORE_DIR
    end

    # Stores post in file store
    def save
      File.write("#{Labook::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one post
    def self.find(find_id)
      post_file = File.read("#{Labook::STORE_DIR}/#{find_id}.txt")
      Post.new JSON.parse(post_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{Labook::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Labook::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
