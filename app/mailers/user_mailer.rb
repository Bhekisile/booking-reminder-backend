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
end
