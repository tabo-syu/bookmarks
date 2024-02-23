class Tag < ApplicationRecord
  has_and_belongs_to_many :bookmarks

  validates :name, presence: true
  validates :color, presence: true
end
