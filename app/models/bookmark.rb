class Bookmark < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :url, url: true
  validates :description, presence: true
end
