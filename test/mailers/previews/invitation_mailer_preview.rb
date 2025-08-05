class InvitationMailerPreview < ActionMailer::Preview
  def invite_user
    user = User.first

    invitation = Invitation.new(
      email: user.email,
      organization: user.organization,
      inviter: user,
      token: SecureRandom.hex(10),
    )
    # Preview this email at http://localhost:3000/rails/mailers/invitation_mailer/invite_user
    InvitationMailer.with(invitation: invitation).invite_user
  end
end