# frozen_string_literal: true

module Labook
  # Service object to create a post for lab
  class CreatePostVote
    # no existent account error
    class VoterNotFoundError < StandardError
      def message = 'Voter cannot be found'
    end

    # no existent post error
    class PostNotFoundError < StandardError
      def message = 'Post cannot be found'
    end

    def self.find_account(voter_username:)
      account = Account.first(username: voter_username)
      raise(VoterNotFoundError) if account.nil?

      account
    end

    def self.find_post(voted_post_id:)
      post = Post.first(post_id: voted_post_id)
      raise(PostNotFoundError) if post.nil?

      post
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.call(voter_username:, voted_post_id:, number:)
      account = find_account(voter_username:)
      post = find_post(voted_post_id:)

      vote = PostVote.first(voter_id: account.account_id, voted_post_id:)

      if vote.nil?
        post.update(vote_sum: post.vote_sum + number)
        account.add_voted_post(post)
        AccountsPost.first(voter_id: account.account_id, voted_post_id:)
                    .add_vote(number:)
      else
        post.update(vote_sum: post.vote_sum - vote.number + number)
        vote.update(number:)
      end

      PostVote.first(voter_id: account.account_id, voted_post_id:)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
