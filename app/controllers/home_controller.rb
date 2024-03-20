class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.order(created_at: :desc).preload(%i[tags user])
    @tags = Tag.all
  end
end
