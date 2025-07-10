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
# user1 = User.create!(
#   name: "Zandi Nkomo",
#   email: "zandi@test.test",
#   password: "password123",
#   password_confirmation: "password123",
#   )

# Create user
user3 = User.create!(
  name: "Girly Lady",
  email: "girly@test.test",
  password: "password789",
  password_confirmation: "password789",
  )

admin = User.create!(
  name: "Admin User",
  email: "admin@test.test",
  password: "password123",
  password_confirmation: "password123",
  role: :admin
)

# Create clients
client1 = Client.create!(name: "Zena", surname: "Jozi", cellphone: "+27722952952", email: "zena@test.test", user: user3)
client2 = Client.create!(name: "Sarah", surname: "Doe", cellphone: "+27995554444", email: "sarah@test.test", user: user3)
client3 = Client.create!(name: "Deborah", surname: "Smith", cellphone: "+27995566444", email: "deb@test.test", user: user3)
client4 = Client.create!(name: "Lee", surname: "Wright", cellphone: "+27995554774", email: "lee@test.test", user: user3)
client5 = Client.create!(name: "Chang", surname: "Chi", cellphone: "+27995554488", email: "chang@test.test", user: user3)
client6 = Client.create!(name: "Girly", surname: "Zuma", cellphone: "+27855554444", email: "girly@test.test", user: user3)
client7 = Client.create!(name: "Norah", surname: "Ndlovu", cellphone: "+27977554444", email: "norah@test.test", user: user3)
client8 = Client.create!(name: "Luios", surname: "Brown", cellphone: "+27995884444", email: "luios@test.test", user: user3)
client9 = Client.create!(name: "Fred", surname: "Nel", cellphone: "+27995559944", email: "fred@test.test", user: user3)
client10 = Client.create!(name: "John", surname: "Bright", cellphone: "+27995554004", email: "john@test.test", user: user3)
client11 = Client.create!(name: "Matthew", surname: "Breakfast", cellphone: "+27995554411", email: "matt@test.test", user: user3)
client12 = Client.create!(name: "Lovebird", surname: "More", cellphone: "+27989554444", email: "more@test.test", user: user3)

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

Booking.create!(
  time: "08:00",
  date: "2025-03-01",
  client_id: client3.id,
  price: "R280.00",
  notes: "Hair treatment appointment",
  payment: false
)

Booking.create!(
  time: "09:00",
  date: "2025-05-15",
  client_id: client12.id,
  price: "R280.00",
  notes: "Hair treatment appointment",
  payment: false
)

Booking.create!(
  time: "12:00",
  date: "2025-03-15",
  client_id: client4.id,
  price: "R450.00",
  notes: "Hair treatment appointment",
  payment: false
)

Booking.create!(
  time: "15:00",
  date: "2025-03-21",
  client_id: client5.id,
  price: "R150.00",
  notes: "Nail appointment",
  payment: false
)

Booking.create!(
  time: "14:00",
  date: "2025-03-09",
  client_id: client6.id,
  price: "R150.00",
  notes: "Nail appointment",
  payment: false
)

Booking.create!(
  time: "15:00",
  date: "2025-04-09",
  client_id: client7.id,
  price: "R550.00",
  notes: "Mathematics tutoring",
  payment: false
)

Booking.create!(
  time: "14:00",
  date: "2025-04-05",
  client_id: client8.id,
  price: "R650.00",
  notes: "Information technology tutoring",
  payment: false
)

Booking.create!(
  time: "14:00",
  date: "2025-04-09",
  client_id: client9.id,
  price: "R150.00",
  notes: "Nail appointment",
  payment: false
)

Booking.create!(
  time: "11:00",
  date: "2025-05-14",
  client_id: client10.id,
  price: "R150.00",
  notes: "Nail appointment",
  payment: false
)

Booking.create!(
  time: "11:30",
  date: "2025-05-14",
  client_id: client11.id,
  price: "R650.00",
  notes: "Mathematics tutoring",
  payment: false
)

Booking.create!(
  time: "14:00",
  date: "2025-05-15",
  client_id: client2.id,
  price: "R150.00",
  notes: "Nail appointment",
  payment: false
)

# Create settings
Setting.create!(
  business_start: "09:00",
  business_end: "17:00",
  name: "My Business",
  address1: "123 Main St",
  address2: "Suite 100, Cityville",
  phone: "123-456-7890",
  email: "business@example.com",
  user_id: user3.id,
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