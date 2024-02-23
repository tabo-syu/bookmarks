class AddNotNullToColumns < ActiveRecord::Migration[7.1]
  def change
    change_column_null :bookmarks, :url, false
    change_column_null :bookmarks, :title, false
    change_column_null :bookmarks, :description, false

    change_column_null :comments, :body, false

    change_column_null :tags, :name, false
    change_column_null :tags, :color, false
  end
end
