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

# Students
students = [
  { email: "john.doe@student.edu", password: "Student123!" },
  { email: "jane.smith@student.edu", password: "Student456!" },
  { email: "naitik.kaythwal@student.edu", password: "StudentJKL!" },
  { email: "purav.patel@student.edu", password: "StudentMNO!" },
  { email: "hitham.rizeq@student.edu", password: "StudentPQR!" },
  { email: "mcneil.mccarley@student.edu", password: "StudentDEF!" },
  { email: "jonnie.nguyen@student.edu", password: "Student789!" },
  { email: "tyler.howell@student.edu", password: "StudentABC!" },
  { email: "lawrence.jones@student.edu", password: "StudentGHI!" },
]

students.each do |student_data|
  User.find_or_create_by(email: student_data[:email]) do |user|
    user.password = student_data[:password]
    user.role = :student
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
end
