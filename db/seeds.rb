# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Clear existing records
# User.destroy_all
# Booking.destroy_all
# Client.destroy_all
# Organization.destroy_all
# Reminder.destroy_all

# Create organizations
# org1 = Organization.create!(
#   business_start: "09:00",
#   business_end: "17:00",
#   name: "The Star",
#   address1: "123 Main St",
#   address2: "Suite 100, Cityville",
#   phone: "123-456-7890",
#   email: "thestar@example.com",
# )

# # Create user
# user3 = User.create!(
#   name: "Girly Lady",
#   email: "girly@test.test",
#   password: "password789",
#   password_confirmation: "password789",
#   email_confirmed: true,
#   organization: org1,
#   trial_start_date: Time.current - 3.months + 3.days,
#   trial_end_date: Time.current + 3.days,
#   subscribed: false,
# )

# user4 = User.create!(
#   name: "Girly Lady",
#   email: "girly@test.test",
#   password: "password789",
#   password_confirmation: "password789",
#   email_confirmed: true,
#   organization: org1,
#   trial_start_date: Time.current - 4.months,
#   trial_end_date: Time.current - 1.month,
#   subscribed: false,
# )

# user5 = User.create!(
#   name: "Girly Lady",
#   email: "girly@test.test",
#   password: "password789",
#   password_confirmation: "password789",
#   email_confirmed: true,
#   organization: org1,
#   trial_start_date: Time.current - 4.months,
#   trial_end_date: Time.current - 1.month,
#   subscribed: true
# )

# admin = User.create!(
#   name: "Admin User",
#   email: "admin@test.test",
#   password: "password123",
#   password_confirmation: "password123",
#   role: :admin,
#   email_confirmed: true,
#   organization: org1,
#   trial_start_date: Time.current - 3.months + 3.days,
#   trial_end_date: Time.current + 3.days,
#   subscribed: false,
# )

# # Create clients
# client1 = Client.create!(name: "Zena", surname: "Jozi", cellphone: "+27722952952", email: "zena@test.test", user: user3, organization: org1)
# client2 = Client.create!(name: "Sarah", surname: "Doe", cellphone: "+27995554444", email: "sarah@test.test", user: user3, organization: org1)
# client3 = Client.create!(name: "Deborah", surname: "Smith", cellphone: "+27995566444", email: "deb@test.test", user: user3, organization: org1)
# client4 = Client.create!(name: "Lee", surname: "Wright", cellphone: "+27995554774", email: "lee@test.test", user: user3, organization: org1)
# client5 = Client.create!(name: "Chang", surname: "Chi", cellphone: "+27995554488", email: "chang@test.test", user: user3, organization: org1)
# client6 = Client.create!(name: "Girly", surname: "Zuma", cellphone: "+27855554444", email: "girly@test.test", user: user3, organization: org1)
# client7 = Client.create!(name: "Norah", surname: "Ndlovu", cellphone: "+27977554444", email: "norah@test.test", user: user3, organization: org1)
# client8 = Client.create!(name: "Luios", surname: "Brown", cellphone: "+27995884444", email: "luios@test.test", user: user3, organization: org1)
# client9 = Client.create!(name: "Fred", surname: "Nel", cellphone: "+27995559944", email: "fred@test.test", user: admin, organization: org1)
# client10 = Client.create!(name: "John", surname: "Bright", cellphone: "+27995554004", email: "john@test.test", user: admin, organization: org1)
# client11 = Client.create!(name: "Matthew", surname: "Breakfast", cellphone: "+27995554411", email: "matt@test.test", user: admin, organization: org1)
# client12 = Client.create!(name: "Lovebird", surname: "More", cellphone: "+27989554444", email: "more@test.test", user: admin, organization: org1)

# # Create bookings
# Booking.create!(
#   time: "10:00",
#   date: Date.today + 1,
#   client_id: client1.id,
#   price: "R200.00",
#   payment: true,
#   notes: "Haircut appointment",
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "14:00",
#   date: Date.today + 2,
#   client_id: client2.id,
#   price: "R150.00",
#   notes: "Nail appointment",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "08:00",
#   date: "2025-03-01",
#   client_id: client3.id,
#   price: "R280.00",
#   notes: "Hair treatment appointment",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "09:00",
#   date: "2025-05-15",
#   client_id: client12.id,
#   price: "R280.00",
#   notes: "Hair treatment appointment",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "12:00",
#   date: "2025-03-15",
#   client_id: client4.id,
#   price: "R450.00",
#   notes: "Hair treatment appointment",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "15:00",
#   date: "2025-03-21",
#   client_id: client5.id,
#   price: "R150.00",
#   notes: "Nail appointment",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "14:00",
#   date: "2025-03-09",
#   client_id: client6.id,
#   price: "R150.00",
#   notes: "Nail appointment",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "15:00",
#   date: "2025-04-09",
#   client_id: client7.id,
#   price: "R550.00",
#   notes: "Mathematics tutoring",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "14:00",
#   date: "2025-04-05",
#   client_id: client8.id,
#   price: "R650.00",
#   notes: "Information technology tutoring",
#   payment: false,
#   organization: org1,
#   user: user3
# )

# Booking.create!(
#   time: "14:00",
#   date: "2025-04-09",
#   client_id: client9.id,
#   price: "R150.00",
#   notes: "Nail appointment",
#   payment: false,
#   organization: org1,
#   user: admin
# )

# Booking.create!(
#   time: "11:00",
#   date: "2025-05-14",
#   client_id: client10.id,
#   price: "R150.00",
#   notes: "Nail appointment",
#   payment: false,
#   organization: org1,
#   user: admin
# )

# Booking.create!(
#   time: "11:30",
#   date: "2025-05-14",
#   client_id: client11.id,
#   price: "R650.00",
#   notes: "Mathematics tutoring",
#   payment: false,
#   organization: org1,
#   user: admin
# )

# Booking.create!(
#   time: "14:00",
#   date: "2025-05-15",
#   client_id: client2.id,
#   price: "R150.00",
#   notes: "Nail appointment",
#   payment: false,
#   organization: org1,
#   user: admin
# )

# # Create reminders
# Reminder.create!(
#   remind_at: DateTime.now + 1.day,
#   message: "Reminder: Your appointment is on #{Date.today + 1}.",
#   booking: Booking.first,
#   message_type: "reminder"
# )
# Reminder.create!(
#   remind_at: DateTime.now + 2.days,
#   message: "Reminder: Your appointment is on #{Date.today + 2}.",
#   booking: Booking.second,
#   message_type: "reminder"
# )
# Reminder.create!(
#   remind_at: DateTime.now,
#   message: "Welcome: Your appointment is booked for #{Date.today + 1}.",
#   booking: Booking.first,
#   message_type: "welcome"
# )
# Reminder.create!(
#   remind_at: DateTime.now,
#   message: "Welcome: Your appointment is booked for #{Date.today + 2}.",
#   booking: Booking.second,
#   message_type: "welcome"
# )

# puts "Seeded #{Organization.count} organizations, #{User.count} users, #{Client.count} clients, #{Booking.count} bookings, and #{Reminder.count} reminders."

# Test users for subscription testing
if Rails.env.development?
  puts "Creating test users for subscription testing..."

  # User with active trial (just started)
  trial_active = User.find_or_create_by(email: 'trial_active@test.com') do |user|
    user.name = 'Active Trial User'
    user.password = 'password123'
    user.trial_start_date = Time.current
    user.trial_end_date = Time.current + 3.months
    user.subscribed = false
  end

  # User with trial expiring soon (3 days left)
  trial_expiring_soon = User.find_or_create_by(email: 'trial_expiring@test.com') do |user|
    user.name = 'Trial Expiring User'
    user.password = 'password123'
    user.trial_start_date = Time.current - 3.months + 3.days
    user.trial_end_date = Time.current + 3.days
    user.subscribed = false
  end

  # User with expired trial
  trial_expired = User.find_or_create_by(email: 'trial_expired@test.com') do |user|
    user.name = 'Expired Trial User'
    user.password = 'password123'
    user.trial_start_date = Time.current - 4.months
    user.trial_end_date = Time.current - 1.month
    user.subscribed = false
  end

  # User with active subscription
  subscribed_user = User.find_or_create_by(email: 'subscribed@test.com') do |user|
    user.name = 'Subscribed User'
    user.password = 'password123'
    user.trial_start_date = Time.current - 4.months
    user.trial_end_date = Time.current - 1.month
    user.subscribed = true
  end

  puts "Test users created:"
  puts "1. trial_active@test.com (Active trial)"
  puts "2. trial_expiring@test.com (Trial expiring in 3 days)"
  puts "3. trial_expired@test.com (Trial expired)"
  puts "4. subscribed@test.com (Active subscription)"
end