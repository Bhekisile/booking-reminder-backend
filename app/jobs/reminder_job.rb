class ReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking && booking.date.future?

    SmsPortalSender.send_sms(
      to: booking.client.cellphone,
      message: "Hi #{booking.client.name}, just a reminder that you have an appointment tomorrow with #{@settings.name} on #{formatted_date(booking)}. Thank you!"
    )
  end
end
