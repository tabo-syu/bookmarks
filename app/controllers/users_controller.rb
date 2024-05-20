class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @bookmarks = @user.bookmarks.preload(:tags)
    @tags = @user.tags
  end
end
