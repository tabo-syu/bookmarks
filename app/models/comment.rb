class Comment < ApplicationRecord
  belongs_to :bookmark
  belongs_to :user
end
