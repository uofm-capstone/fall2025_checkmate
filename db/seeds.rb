# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# Ensures users are created only if they do not already exist
User.find_or_create_by(email: "email@email.com") do |user|
  user.password = "123456"
end

# Admin for Professor Amy Cook
User.find_or_create_by(email: "AmyCook@admin.com") do |user|
  user.password = "Admin123!"
  user.admin = true
end

# Admin for Professor Brandon Booth
User.find_or_create_by(email: "BrandonBooth@admin.com") do |user|
  user.password = "Admin456!"
  user.admin = true
end
