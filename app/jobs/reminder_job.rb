class ReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    client = booking.client

    message = "Hi #{client.name}, this is a reminder for your appointment on #{bookings.date.strftime('%A at %I:%M %p')}."

    # Email reminder
    # ReminderMailer.appointment_reminder(client, booking).deliver_now

    # SMS
    SmsPortalSender.send_sms(
      to: client.cellphone, # Should be like +27XXXXXXXXX
      message: message
    )

    # Save message record
    Reminder.create!(
      booking: booking,
      message_type: "reminder_sms",
      message: "SMS reminder sent to #{client.cellphone} for #{bookings.date.strftime('%A at %I:%M %p')}",
      remind_at: Time.current
    )
  end
end
