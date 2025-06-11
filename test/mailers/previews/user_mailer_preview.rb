# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def signup_email
    # Preview this email at http://localhost:3000/rails/mailers/user_mailer/signup_email
    user = User.first
    UserMailer.signup_email(user)
    # UserMailer.with(user: User.first).signup_email
  end

  def reset_password_email
    user = User.last
    UserMailer.reset_password_email(user)
  end
end
