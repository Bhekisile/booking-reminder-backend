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
User.destroy_all
Booking.destroy_all
Client.destroy_all
Setting.destroy_all
Reminder.destroy_all

# Create user
user1 = User.create!(
  name: "Zandi Nkomo",
  email: "zandi@test.test",
  password: "password123",
  password_confirmation: "password123",
  )

# Create clients
client1 = Client.create!(name: "Zena", surname: "Jozi", cellphone: "0722952952", email: "zena@test.test", user: user1)
client2 = Client.create!(name: "Sarah", surname: "Doe", cellphone: "0995554444", email: "sarah@test.test", user: user1)

# Create bookings
Booking.create!(
  time: "10:00",
  date: Date.today + 1,
  client_id: client1.id,
  price: "R200.00",
  payment: true,
  notes: "Haircut appointment",
)

Booking.create!(
  time: "14:00",
  date: Date.today + 2,
  client_id: client2.id,
  price: "R150.00",
  notes: "Nail appointment",
  payment: false
)

# Create settings
Setting.create!(
  business_start: "09:00",
  business_end: "17:00",
  notification: true,
  user_id: user1.id,
)

# Create reminders
Reminder.create!(
  remind_at: DateTime.now + 1.day,
  message: "Reminder: Your appointment is on #{Date.today + 1}.",
  booking: Booking.first,
  message_type: "reminder"
)
Reminder.create!(
  remind_at: DateTime.now + 2.days,
  message: "Reminder: Your appointment is on #{Date.today + 2}.",
  booking: Booking.second,
  message_type: "reminder"
)
Reminder.create!(
  remind_at: DateTime.now,
  message: "Welcome: Your appointment is booked for #{Date.today + 1}.",
  booking: Booking.first,
  message_type: "welcome"
)
Reminder.create!(
  remind_at: DateTime.now,
  message: "Welcome: Your appointment is booked for #{Date.today + 2}.",
  booking: Booking.second,
  message_type: "welcome"
)