class CommentsController < ApplicationController
  def create
    @bookmark = Bookmark.find(params[:bookmark_id])
    @comment = @bookmark.comments.create(comment_params)

    redirect_to bookmark_path(@bookmark)
  end

  def destroy
    @bookmark = Bookmark.find(params[:bookmark_id])
    @comment = @bookmark.comments.find(params[:id])
    @comment.destroy

    redirect_to bookmark_path(@bookmark), status: :see_other
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
