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
  user.role = :admin
end

# Admin for Professor Brandon Booth
User.find_or_create_by(email: "BrandonBooth@admin.com") do |user|
  user.password = "Admin456!"
  user.admin = true
  user.role = :admin
end

# Admin for Derron Dowdy
User.find_or_create_by(email: "Dmdowdy@memphis.edu") do |user|
  user.password = "Admin789!"
  user.admin = true
  user.role = :admin
end

# Adding more seed data

# Teaching Assistants
User.find_or_create_by(email: "doe.john@ta.edu") do |user|
  user.password = "TApass123!"
  user.role = :ta
end

User.find_or_create_by(email: "smith.jame@ta.edu") do |user|
  user.password = "TApass456!"
  user.role = :ta
end

=begin

# Students
emails = [
  "john.doe@student.edu",
  "jane.smith@student.edu",
  "naitik.kaythwal@student.edu",
  "purav.patel@student.edu",
  "hitham.rizeq@student.edu",
  "mcneil.mccarley@student.edu",
  "jonnie.nguyen@student.edu",
  "tyler.howell@student.edu",
  "lawrence.jones@student.edu",
]

emails.each do |raw|
  email = raw.downcase.strip
  Student.find_or_create_by!(email: email) do |s|
    user = email.split("@").first
    first, last = user.split(".", 2)
    s.full_name = [first, last].compact.map { _1.capitalize }.join(" ")
    # leave github_username/team_id nil to avoid unique(team_id, github_username)
  end
end
  
# Guest users
guests = [
  { email: "client1@company.com", password: "GuestPass1!" },
  { email: "client2@nonprofit.org", password: "GuestPass2!" },
  { email: "sponsor1@business.com", password: "GuestPass3!" },
  { email: "sponsor2@enterprise.net", password: "GuestPass4!" },
  { email: "observer@external.edu", password: "GuestPass5!" }
]

guests.each do |guest_data|
  User.find_or_create_by(email: guest_data[:email]) do |user|
    user.password = guest_data[:password]
    user.role = :guest
  end

=end