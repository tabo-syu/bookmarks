class DiscordRecipient < ApplicationRecord
  has_and_belongs_to_many :tags

  validates :channel_id, presence: true
end
