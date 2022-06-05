# frozen_string_literal: true

module Labook
  # Service object to create a comment for a post
  class CreateComment
    # no existent account error
    class CommenterNotFoundError < StandardError
      def message = 'Commenter cannot be found'
    end

    # no existent post error
    class PostNotFoundError < StandardError
      def message = 'Post cannot be found'
    end

    def self.call(commenter_account:, commented_post_id:, comment_data:)
      account = Account.first(username: commenter_account)
      raise(CommenterNotFoundError) if account.nil?

      post = Post.first(post_id: commented_post_id)
      raise(PostNotFoundError) if post.nil?

      comment = Comment.first(commenter_id: account.account_id, commented_post_id:)
      account.add_commented_post(post) if comment.nil?
      AccountsCommentPost.first(commenter_id: account.account_id, commented_post_id:)
                         .add_comment(comment_data)
    end
  end
end
