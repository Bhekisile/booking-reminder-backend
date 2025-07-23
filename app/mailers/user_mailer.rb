class UserMailer < ApplicationMailer
  default from: 'bheki@bjsoftwaredev.com'

  def welcome_email(user)
    @user = user
    # @login_url = 'http://localhost:3001/login'
    # @url = params[:url] || "https://booking-reminder.expo.app/login"
    # @token = params[:token]
    # @token = user.signed_id(purpose: "signup", expires_in: 15.minutes)
    mail(to: @user.email, subject: 'Welcome to Bookify!')
    # mail subject: 'Welcome to Bookify!'
  end

  def reset_password_email(user)
    @user = user
    User.send_reset_password_instructions(email: params[:email])
    @token = params[:token]
    # @token = @user.signed_id(purpose: "password_reset", expires_in: 15.minutes)
    mail(to: @user.email, subject: 'Reset your password')
  end
end
