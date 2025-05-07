class ReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    client = booking.client

    reminder = Reminder.create!(
      booking: booking,
      message_type: "reminder",
      message: "Reminder: Your appointment is on #{booking.date.strftime("%A at %I:%M %p")}.",
      remind_at: Time.current
    )

    # You could integrate SMS or email sending here
  end
end
