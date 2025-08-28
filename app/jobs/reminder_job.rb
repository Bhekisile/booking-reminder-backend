class ReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking && booking.booked_date.future?

    SmsPortalSender.send_sms(
      to: booking.client.cellphone,
      message: "Hi #{booking.client.name}, This is just a reminder that you have an appointment tomorrow with #{booking.organization.name} on #{booking.formatted_datetime}. Thank you!"
    )
  end
end
