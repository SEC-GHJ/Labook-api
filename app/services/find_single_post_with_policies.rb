# frozen_string_literal: true

module Labook
  # Service object to find post with policies and votes
  class FindSinglePostWithPolicies
    def self.call(post_id:, auth_account:)
      post = Post.where(post_id:).first
      raise('Post not found') if post.nil?

      requestor = auth_account.nil? ? nil : Account.first(account_id: auth_account['account_id'])

      comments = post.clone.to_h[:include][:comments].map do |comment|
        commment_arr = comment.map do |sub_comment|
          # add policy in comments
          account = Account.first(account_id: sub_comment.to_h[:attributes][:commenter_id])
          policy = AccountPolicy.new(requestor, account)

          # add voted in comments
          vote = requestor.nil? ? nil : CommentVote.first(voter_id: requestor.account_id,
                                                          voted_comment_id: sub_comment.to_h[:attributes][:comment_id])
          voted_number = vote.nil? ? 0 : vote.number

          [sub_comment.to_h.merge(policies: policy.summary).merge(voted_number:)]
        end
      end.flatten

      # add policy in post
      account = Account.first(account_id: post.poster_id)
      policy = AccountPolicy.new(requestor, account)

      # add voted in post
      vote = requestor.nil? ? nil : PostVote.first(voter_id: requestor.account_id,
                                                   voted_post_id: post_id)
      voted_number = vote.nil? ? 0 : vote.number

      output = post.to_h.merge(policies: policy.summary).merge(voted_number:)
      output[:include][:comments].replace(comments)
      output.to_json
    end
  end
end
