class UserMailer < ApplicationMailer
  default from: 'bheki@bjsoftwaredev.com'

  def welcome_email
    @user = params[:user]
    mail(to: @user.email, subject: 'Welcome to Bookify!')
  end

  def reset_password_email(user, reset_password_token)
    @user = user
    mail(to: @user.email, subject: 'Reset your password')
  end

  def onboarding_email
    @user = params[:user]
    @app_name = "Booking Reminder / Bookify"
    @video_url = "https://drive.google.com/file/d/1HW9s5BVR6MzS7wxZY9EZJQpJA5auZUag/view?usp=sharing"
    @guide_url = "https://docs.google.com/document/d/1TAUBY9jFHATmClDxN8XXOOn2wwoioQU-V7Q8chib2xQ/edit?usp=sharing"
    mail(to: @user.email, subject: "Welcome to #{@app_name} 🎉")
  end
end
