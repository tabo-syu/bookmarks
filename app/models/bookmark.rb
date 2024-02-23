class Bookmark < ApplicationRecord
  validates :title, presence: true
  validates :url, url: true
  validates :description, presence: true
end
