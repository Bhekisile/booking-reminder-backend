class UserMailer < ApplicationMailer
  # default from: "bhekisilejozi@gmail.com"
  default from: 'no-reply@example.com'

  def signup_email(user)
    @user = user
    # @token = user.signed_id(purpose: "signup", expires_in: 15.minutes)
    mail(to: @user.email, subject: 'Welcome to Bookify!')
  end

  def reset_password_email(user)
    @user = user
    User.send_reset_password_instructions(email: params[:email])
    @token = user.signed_id(purpose: "password_reset", expires_in: 15.minutes)
    mail(to: @user.email, subject: 'Reset your password')
  end
end
