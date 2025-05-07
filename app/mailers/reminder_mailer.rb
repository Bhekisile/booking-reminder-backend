class ReminderMailer < ApplicationMailer
  def appointment_reminder(client, appointment)
    @client = client
    @appointment = appointment
    mail(to: @client.email, subject: 'Appointment Reminder')
  end
end
