class Api::V1::InvitationsController < ApplicationController

  def create
    organization = Organization.find(invitation_params[:organization_id])
    
    # Check if organization can add more users
    unless organization.can_add_user?
      return render json: { 
        error: "Maximum of #{Organization::MAX_USERS} users allowed per organization. Current count: #{organization.user_count}" 
      }, status: :unprocessable_entity
    end

    # Check if user with this email already exists in the organization
    if organization.users.joins('LEFT JOIN invitations ON invitations.email = users.email')
                     .where('users.email = ? OR invitations.email = ?', 
                            invitation_params[:email], invitation_params[:email])
                     .exists?
      return render json: { 
        error: "User with this email already exists in the organization or has a pending invitation" 
      }, status: :unprocessable_entity
    end

    @invitation = Invitation.new(invitation_params)

    if @invitation.save
      InvitationMailer.invite_user(invitation: @invitation, token: @invitation.token).deliver_later

      render json: { 
        message: "Invitation sent", 
        token: @invitation.token,
        remaining_slots: organization.remaining_user_slots - 1  # -1 for the pending invitation
      }, status: :created
    else
      render json: { error: @invitation.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Organization not found" }, status: :not_found
  end

  def accept
    invitation = Invitation.find_by(token: params[:token])
    
    if !invitation
      return render json: { error: "Invalid invitation token" }, status: :not_found
    end

    if invitation.expired?
      return render json: { error: "Invitation has expired" }, status: :gone
    end

    organization = invitation.organization

    # Double-check user limit before accepting
    unless organization.can_add_user?
      return render json: { 
        error: "Organization has reached maximum user limit" 
      }, status: :unprocessable_entity
    end

    # Create or update user
    user = User.find_or_initialize_by(email: invitation.email)
    
    if user.persisted?
      # Existing user joining organization
      if user.organization_id.present?
        return render json: { 
          error: "User already belongs to an organization" 
        }, status: :unprocessable_entity
      end
      
      user.update!(
        organization: organization,
        role: 'user'
      )
    else
      # New user
      user.assign_attributes(
        name: invitation.name || invitation.email.split('@').first,
        organization: organization,
        role: 'user',
        password: SecureRandom.hex(12), # Temporary password
        # Don't set trial dates for organization members
        trial_start_date: nil,
        trial_end_date: nil
      )
      
      unless user.save
        return render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Delete the invitation after successful acceptance
    invitation.destroy

    render json: { 
      message: "Successfully joined organization",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        organization_id: user.organization_id,
        role: user.role
      }
    }, status: :ok
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :organization_id, :inviter_id, :name)
  end
end
