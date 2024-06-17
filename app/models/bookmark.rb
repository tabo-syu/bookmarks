class Bookmark < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :comments

  validates :title, presence: true
  validates :url, url: true
  validates :description, presence: true
end
