class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @bookmarks = @user.bookmarks.order(created_at: :desc).preload(:tags)
    @tags = @user.tags
  end
end
