class UserMailer < ApplicationMailer
  default from: 'bheki@bjsoftwaredev.com'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Bookify!')
  end

  def reset_password_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Reset your password')
  end
end
