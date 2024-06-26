class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable

  validates :name, presence: true
  validates :password, presence: true

  has_many :bookmarks, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :tags, dependent: :destroy
end
