class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.all
    @tags = Tag.all
    @comments = Comment.all
  end
end
