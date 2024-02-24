class BookmarksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  # Read
  def index
    @bookmarks = Bookmark.all
  end

  def show
    @bookmark = Bookmark.find(params[:id])
  end

  # Create
  def new
    @bookmark = Bookmark.new
  end

  def create
    @bookmark = current_user.bookmarks.new(bookmark_params)

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
    params.require(:bookmark).permit(:title, :url, :description, tag_ids: [])
  end
end
