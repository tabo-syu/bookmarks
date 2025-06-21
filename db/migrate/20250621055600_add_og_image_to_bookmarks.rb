class AddOgImageToBookmarks < ActiveRecord::Migration[7.1]
  def self.up
    add_column :bookmarks, :og_image_url, :text
  end

  def self.down
    remove_column :bookmarks, :og_image_url
  end
end