class Tag < ApplicationRecord
  has_and_belongs_to_many :bookmarks
  belongs_to :user

  validates :name, presence: true
end
