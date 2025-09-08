# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email(user = User.first)
    # user = User.last
    # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome_email
    UserMailer.with(user: user).welcome_email
  end

  def reset_password_email(user = User.first, reset_password_token= SecureRandom.urlsafe_base64.to_s)
    # user = User.last
    UserMailer.with(user: user).reset_password_email(reset_password_token)
  end

  def onboarding_email(user = User.first)
    UserMailer.with(user: user).onboarding_email
  end
end
