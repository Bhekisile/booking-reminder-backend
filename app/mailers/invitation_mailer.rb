class InvitationMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def invite_user(invitation)
    @invitation = invitation[:invitation]
    @token = invitation[:token]
    @url = "#{ENV['FRONTEND_URL']}/RegisterMember?token=#{@token}"

    mail(to: @invitation.email, subject: 'You’ve been invited to join the platform')
  end
end
