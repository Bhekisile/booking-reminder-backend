# app/mailers/custom_devise_mailer.rb
class CustomDeviseMailer < Devise::Mailer
  # helper :application
  # include Devise::Controllers::UrlHelpers

  def signup_instructions(record, opts = {})
    @user = record
    devise_mail(record, :signup_instructions, opts)
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :reset_password_instructions, opts)
  end

  # def reset_password_instructions(record, token, opts = {})
  #   opts[:redirect_url] = "bookify://reset-password?token=#{token}"
  #   super
  # end
end
