class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.order(created_at: :desc).preload(%i[tags user]).page(params[:page])
    @tags = Tag.all.order(created_at: :desc)
  end
end
