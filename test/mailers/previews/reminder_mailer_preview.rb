# Preview all emails at http://localhost:3000/rails/mailers/reminder_mailer
class ReminderMailerPreview < ActionMailer::Preview
  def appointment_reminder
    # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/appointment_reminder
    client = Client.first
    appointment = Booking.last
    ReminderMailer.appointment_reminder(client, appointment)
  end
end
