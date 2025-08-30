class Api::V1::UsersController < ApplicationController
  include Devise::Controllers::Helpers
  include Rails.application.routes.url_helpers

  skip_before_action :authenticate_user!, only: [:confirm_email, :show]
  before_action :set_user, only: [:show, :subscription_status]
  before_action :authenticate_admin!, only: [:destroy_membership]

  # GET /api/v1/users
  # Show all users in the organization
  def index
    @users = current_user.organization.users
    render json: @users
  end

  # GET /api/v1/users/1
  def show
    user = User.find(params[:id])
    avatar_url = user.avatar.attached? ? url_for(user.avatar) : nil

    render json: {
      id: user.id,
      name: user.name,
      avatar_url: avatar_url
    }
  end

  def confirm_email
    user = User.find_by(confirm_token: params[:id])
    if user
      user.email_activate
      
      redirect_to "#{ENV['FRONTEND_URL']}/loginConfirmation?confirmed=true", allow_other_host: true
    else
      redirect_to "#{ENV['FRONTEND_URL']}/loginConfirmation?error=invalid_token", allow_other_host: true
    end
  end

  def user_permissions
    permissions = {
      can_create_booking: can?(:create, Booking),
      can_view_own_bookings: can?(:read, Booking.new(user: current_user)), # Check if they can read a new booking associated with them
      can_update_any_own_booking: can?(:update, Booking.new(user: current_user)), # Check if they can update any booking associated with them
      can_delete_any_own_booking: can?(:destroy, Booking.new(user: current_user)), # Check if they can destroy any booking associated with them
      can_view_all_bookings: can?(:read, Booking),
    }
    render json: permissions
  end

  def current
    avatar_url = current_user.avatar.attached? ? url_for(current_user.avatar) : nil

    render json: {
      user_id: current_user.id,
      email: current_user.email,
      name: current_user.name,
      role: current_user.role,
      avatar_url: avatar_url,
      organization_id: current_user.organization_id,
      subscribed: current_user.subscribed?,
      trial_start_date: current_user.trial_start_date,
    }
  end

  #  DELETE api/v1/users/:id
  # Remove a user from the admin's organization
  def destroy_membership
    user = current_user.organization.users.find(params[:id])

    if user.admin?
      return render json: { error: "Admin cannot be removed" }, status: :forbidden
    end

    # Soft remove → set organization_id to nil
    if user.update(organization: nil)
      render json: { message: "User removed from organization" }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # sign out the user
  def destroy
    if current_user.destroy
      render json: { message: 'Account deleted successfully.' }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/users/1
  def update
    if current_user.update(user_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_avatar
    begin
      Rails.logger.info "Params for update_avatar: #{params.inspect}"
      Rails.logger.info "Avatar param present? #{params[:avatar].present?}"
      Rails.logger.info "Type of params[:avatar]: #{params[:avatar].class}"

      if params[:avatar].present? && params[:avatar].is_a?(ActionDispatch::Http::UploadedFile)
        # The Tempfile object holds the actual binary data
        local_tempfile_path = params[:avatar].tempfile
        calculated_md5 = Digest::MD5.file(local_tempfile_path).base64digest
        puts "Checksum calculated from original uploaded tempfile: #{calculated_md5}"
        current_user.avatar.attach(params[:avatar])

        # Explicitly save the user to persist the attachment and trigger validations
        if current_user.save # <--- ADD THIS LINE!
          Rails.logger.info "Avatar attached successfully? #{current_user.avatar.attached?}"
          Rails.logger.info "User errors after save: #{current_user.errors.full_messages if current_user.errors.present?}"
          Rails.logger.info "Active Storage errors after save: #{current_user.avatar.errors.full_messages if current_user.avatar.errors.present?}"

          if current_user.avatar.attached?
            render json: { avatar_url: url_for(current_user.avatar) }, status: :ok
          else
            # This should ideally not be hit if @user.save was true, but good for robustness
            render json: {
              error: "Failed to attach avatar (post-save check)",
              details: current_user.errors.full_messages + (current_user.avatar.errors.full_messages if current_user.avatar.errors.present? ).to_a
            }, status: :unprocessable_entity
          end
        else
          # If @user.save returns false (due to validation errors)
          render json: {
            error: "Failed to update user due to validation errors",
            details: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      else
        render json: { error: "No valid image uploaded or invalid file format" }, status: :bad_request
      end
    rescue ActiveStorage::IntegrityError => e
      Rails.logger.error "Integrity error: #{e.message}"
      Rails.logger.error "Blob key: #{current_user.avatar.blob&.key}"
      raise
    end
  end

  def destroy_avatar
    # Check if an avatar is attached before attempting to purge
    if current_user.avatar.attached?
      current_user.avatar.purge # This deletes the file from S3 and the record from the database
      render json: { message: "Avatar successfully deleted" }, status: :ok
    else
      render json: { error: "No avatar to delete" }, status: :not_found
    end
  rescue => e
    # Catch any unexpected errors during deletion
    Rails.logger.error "Error deleting avatar for user #{current_user.id}: #{e.message}"
    render json: { error: "Failed to delete avatar", details: e.message }, status: :internal_server_error
  end

  def subscription_status
    # For organization members, include organization info
    organization_info = if @user.organization_id.present?
      admin_user = @user.organization.admin_user
      {
        organization_id: @user.organization_id,
        is_organization_member: true,
        admin_subscription_status: admin_user&.subscribed?,
        admin_trial_active: admin_user&.trial_active?,
        admin_trial_days_remaining: admin_user&.trial_days_remaining,
        organization_user_count: @user.organization.user_count,
        organization_remaining_slots: @user.organization.remaining_user_slots
      }
    else
      {
        is_organization_member: false
      }
    end

    render json: {
      has_active_subscription: @user.has_active_subscription?,
      trial_active: @user.trial_active?,
      trial_days_remaining: @user.trial_days_remaining,
      trial_status: @user.trial_status,
      subscribed: @user.subscribed?,
      trial_start_date: @user.trial_start_date,
      trial_end_date: @user.trial_end_date,
      subscription_status: @user.subscription_status,
      can_access_features: {
        basic_features: @user.can_access_feature?(:basic_features),
        premium_features: @user.can_access_feature?(:premium_features),
        unlimited_bookings: @user.can_access_feature?(:unlimited_bookings)
      },
      role: @user.role,
      **organization_info
    }
  end

  # admin remove user
  def remove_user
    @user.destroy
    render json: { message: "User successfully removed" }, status: :ok
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def avatar_params
    params.permit(:avatar)
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end
end
