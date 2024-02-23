class CreateBookmarkHasTags < ActiveRecord::Migration[7.1]
  def change
    create_table :bookmark_has_tags do |t|
      t.references :bookmark, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
