class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @bookmark = Bookmark.find(params[:bookmark_id])
    @comment = @bookmark.comments.create(comment_params.merge(user: current_user))

    Bot.send_message(
      Rails.application.credentials.discord.channel_id,
      <<-EOS
**新しいコメントが投稿されました！**

> #{current_user.name}: #{@comment.body}

#{@bookmark.url}
      EOS
    )

    redirect_to bookmark_path(@bookmark)
  end

  def destroy
    @bookmark = Bookmark.find(params[:bookmark_id])
    @comment = @bookmark.comments.where(user: current_user).find(params[:id])
    @comment.destroy

    redirect_to bookmark_path(@bookmark), status: :see_other
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
