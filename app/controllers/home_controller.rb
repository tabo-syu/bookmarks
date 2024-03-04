class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.includes(%i[tags user])
  end
end
