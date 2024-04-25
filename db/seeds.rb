# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


user = User.find_or_create_by(email: "email@email.com") do |user|
  user.password = "123456"
  puts "Creating user with email@email.com"
end

puts "User created: #{user.id}" if user.persisted?

# Admin for Professor Amy Cook
amy = User.find_or_create_by(email: "AmyCook@admin.com") do |user|
  user.password = "Admin1"
  user.admin = true
  puts "Creating admin for Amy Cook"
end

puts "Admin Amy created: #{amy.id}" if amy.persisted?

# Admin for Professor Brandon Booth
brandon = User.find_or_create_by(email: "BrandonBooth@admin.com") do |user|
  user.password = "Admin2"
  user.admin = true
  puts "Creating admin for Brandon Booth"
end

puts "Admin Brandon created: #{brandon.id}" if brandon.persisted?
