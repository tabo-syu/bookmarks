class CreateDiscordRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :discord_recipients do |t|
      t.string :channel_id

      t.timestamps
    end

    create_table :discord_recipients_tags, id: false do |t|
      t.belongs_to :discord_recipient
      t.belongs_to :tag
    end
  end
end
