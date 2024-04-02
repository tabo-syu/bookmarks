class TagsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  # Read
  def index
    @tags = Tag.preload(:bookmarks)
  end

  def show
    @tag = Tag.preload(bookmarks: %i[tags user]).find(params[:id])
  end

  # Create
  def new
    @tag = Tag.new
  end

  def create
    @tag = current_user.tags.new(tag_params)

    if @tag.save
      redirect_to @tag
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Update
  def edit
    @tag = current_user.tags.find(params[:id])
  end

  def update
    @tag = current_user.tags.find(params[:id])

    if @tag.update(tag_params)
      redirect_to @tag
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete
  def destroy
    @tag = current_user.tags.find(params[:id])
    @tag.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
