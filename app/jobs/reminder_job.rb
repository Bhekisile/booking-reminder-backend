class ReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    client = booking.client

    ReminderMailer.appointment_reminder(client, booking).deliver_now
    # Send a reminder message to the client

    # reminder = 
    Reminder.create!(
      booking: booking,
      message_type: "reminder_email",
      message: "Email reminder sent to #{client.email} for #{booking.date}",
      remind_at: Time.current
    )

    # You could integrate SMS or email sending here
  end
end
