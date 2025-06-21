require 'nokogiri'
require 'open-uri'

class BookmarksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  # Read
  def index
    @bookmarks = Bookmark.order(created_at: :desc).preload(%i[tags comments]).page(params[:page])
  end

  def show
    @bookmark = Bookmark.preload(comments: :user).find(params[:id])
  end

  # Create
  def new
    @bookmark = Bookmark.new
    @bookmark.comments.build
  end

  def create
    @bookmark = current_user.bookmarks.new(bookmark_params)
    @bookmark.comments.each { |comment| comment.user = current_user }
    @bookmark.comments = @bookmark.comments.filter { |comment| !comment.body.empty? }

    begin
      uri = URI.parse(@bookmark.url)

      doc = Nokogiri::HTML(uri.open, nil, 'UTF-8')
      title = doc.title
      desc = doc.css('//meta[name$="description"]/@content').to_s
      og_image = extract_og_image(doc, uri)

      @bookmark.title = title
      @bookmark.description = desc.empty? ? title : desc
      
      if og_image
        @bookmark.og_image_url = og_image
        download_and_attach_image(@bookmark, og_image)
      end
    rescue StandardError => e
      @bookmark.errors.add(:url, '無効なURL')
      render :new, status: :unprocessable_entity and return
    end

    if @bookmark.save
      message = "新しいブックマークが登録されました！\n#{@bookmark.url}"

      message << "\nコメント : " if @bookmark.comments.size > 0
      @bookmark.comments.each do |comment|
        message << "#{comment.body}\n"
      end

      Bot.send_message(
        Rails.application.credentials.discord.channel_id,
        message
      )

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
    params.require(:bookmark).permit(:url, tag_ids: [], comments_attributes: [:body])
  end

  def extract_og_image(doc, base_uri)
    # Try og:image first
    og_image = doc.at_css('meta[property="og:image"]')&.[]('content')
    return resolve_image_url(og_image, base_uri) if og_image

    # Fallback to twitter:image
    twitter_image = doc.at_css('meta[name="twitter:image"]')&.[]('content')
    return resolve_image_url(twitter_image, base_uri) if twitter_image

    nil
  end

  def resolve_image_url(image_url, base_uri)
    return nil if image_url.blank?

    # If image URL is relative, make it absolute
    if image_url.start_with?('//')
      "https:#{image_url}"
    elsif image_url.start_with?('/')
      "#{base_uri.scheme}://#{base_uri.host}#{image_url}"
    elsif !image_url.start_with?('http')
      "#{base_uri.scheme}://#{base_uri.host}/#{image_url}"
    else
      image_url
    end
  end

  def download_and_attach_image(bookmark, image_url)
    return unless image_url

    begin
      uri = URI.parse(image_url)
      response = uri.open
      
      # Get filename from URL or generate one
      filename = File.basename(uri.path)
      filename = "og_image_#{SecureRandom.hex(8)}.jpg" if filename.blank? || !filename.include?('.')
      
      # Attach the image to the bookmark
      bookmark.og_image.attach(
        io: response,
        filename: filename,
        content_type: response.content_type || 'image/jpeg'
      )
    rescue StandardError => e
      Rails.logger.warn "Failed to download og:image from #{image_url}: #{e.message}"
      # Continue without failing the bookmark creation
    end
  end
end
