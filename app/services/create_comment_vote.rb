# frozen_string_literal: true

module Labook
  # Service object to create a vote for comment
  class CreateCommentVote
    # no existent account error
    class VoterNotFoundError < StandardError
      def message = 'Voter cannot be found'
    end

    # no existent comment error
    class CommentNotFoundError < StandardError
      def message = 'Comment cannot be found'
    end

    def self.find_account(voter_account:)
      account = Account.first(account: voter_account)
      raise(VoterNotFoundError) if account.nil?

      account
    end

    def self.find_comment(voted_comment_id:)
      comment = Comment.first(comment_id: voted_comment_id)
      raise(CommentNotFoundError) if comment.nil?

      comment
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.call(voter_account:, voted_comment_id:, number:)
      account = find_account(voter_account:)
      comment = find_comment(voted_comment_id:)

      vote = CommentVote.first(voter_id: account.account_id, voted_comment_id:)

      if vote.nil?
        comment.update(vote_sum: comment.vote_sum + number)
        account.add_voted_comment(comment)
        AccountsComment.first(voter_id: account.account_id, voted_comment_id:)
                       .add_vote(number:)
      else
        comment.update(vote_sum: comment.vote_sum - vote.number + number)
        vote.update(number:)
      end

      CommentVote.first(voter_id: account.account_id, voted_comment_id:)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
