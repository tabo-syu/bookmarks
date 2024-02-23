class Bookmark < ApplicationRecord
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :url, url: true
  validates :description, presence: true
end
