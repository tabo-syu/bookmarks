# frozen_string_literal: true
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

User.create!(
  password: 'password',
  name: 'test_user',
)

Tag.create!(
  name: 'test_tag_1',
  user_id: 1
)

14.times do |n|
  Bookmark.create!(
    title: "test_title_#{n + 1}",
    url: "https://example.com/test_#{n + 1}",
    description: "test_#{n + 1}",
    user_id: 1,
    tag_ids: [1]
  )
end
