require 'nokogiri'
require 'open-uri'

class BookmarksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  # Read
  def index
    @bookmarks = Bookmark.preload(%i[tags comments])
  end

  def show
    @bookmark = Bookmark.preload(comments: :user).find(params[:id])
  end

  # Create
  def new
    @bookmark = Bookmark.new
  end

  def create
    @bookmark = current_user.bookmarks.new(bookmark_params)

    doc = Nokogiri::HTML(URI.parse(@bookmark.url).open, nil, 'UTF-8')
    @bookmark.title = doc.title
    @bookmark.description = doc.css('//meta[name$="description"]/@content').to_s

    if @bookmark.save
      redirect_to @bookmark
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Update
  def edit
    @bookmark = current_user.bookmarks.find(params[:id])
  end

  def update
    @bookmark = current_user.bookmarks.find(params[:id])

    if @bookmark.update(bookmark_params)
      redirect_to @bookmark
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete
  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    @bookmark.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:url, tag_ids: [])
  end
end
