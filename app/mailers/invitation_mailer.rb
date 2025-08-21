class InvitationMailer < ApplicationMailer
  default from: 'bheki@bjsoftwaredev.com'

  def invite_user(invitation)
    @invitation = invitation[:invitation]
    @token = invitation[:token]
    @url = "#{ENV['FRONTEND_URL']}/registerMember?token=#{@token}"

    mail(to: @invitation.email, subject: 'Invitation to join the platform')
  end
end
