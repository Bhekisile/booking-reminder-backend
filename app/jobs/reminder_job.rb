class ReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    client = booking.client

    message = "Hi #{client.name}, this is a reminder for your appointment on #{appointment.date.strftime('%A at %I:%M %p')}."

    # Email reminder
    # ReminderMailer.appointment_reminder(client, booking).deliver_now

    # SMS
    SmsPortalSender.send_sms(
      to: client.phone_number, # Should be like +27XXXXXXXXX
      message: message
    )

    # Save message record
    Reminder.create!(
      booking: booking,
      message_type: "reminder_sms",
      message: "SMS reminder sent to #{client.cellphone} for #{booking.date}",
      remind_at: Time.current
    )
  end
end
