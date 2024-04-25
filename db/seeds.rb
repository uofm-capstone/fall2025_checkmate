# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


## Ensure general user is created only if they do not exist
User.find_or_create_by(email: "email@email.com") do |user|
  user.password = "123456"
end

# Ensure admin for Professor Amy Cook is created only if they do not exist
User.find_or_create_by(email: "AmyCook@admin.com") do |user|
  user.password = "Admin1"
  user.admin = true
end

# Ensure admin for Professor Brandon Booth is created only if they do not exist
User.find_or_create_by(email: "BrandonBooth@admin.com") do |user|
  user.password = "Admin2"
  user.admin = true
end
