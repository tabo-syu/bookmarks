class Comment < ApplicationRecord
  belongs_to :bookmark
  counter_culture :bookmark

  belongs_to :user
end
