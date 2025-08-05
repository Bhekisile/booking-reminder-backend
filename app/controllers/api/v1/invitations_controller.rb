# app/controllers/invitations_controller.rb
class Api::V1::InvitationsController < ApplicationController

  def create
    @invitation = Invitation.new(invitation_params)

    if @invitation.save
      InvitationMailer.invite_user({ invitation: @invitation, token: @invitation.token }).deliver_later

      render json: { message: "Invitation sent", token: @invitation.token }, status: :created
    else
      render json: { error: @invitation.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invitation not found" }, status: :not_found
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :organization_id, :inviter_id, :name)
  end
end
