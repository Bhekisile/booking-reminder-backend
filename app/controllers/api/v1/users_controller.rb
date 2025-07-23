class Api::V1::UsersController < ApplicationController
  include Devise::Controllers::Helpers
  include Rails.application.routes.url_helpers

  before_action :authenticate_user!, only: [:update, :update_avatar, :current, :destroy]
  before_action :set_user, only: [:update, :update_avatar]

  # GET /api/v1/users
  def index
    @users = User.all
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
      render json: { message: "Email confirmed successfully. You can now log in." }, status: :ok
    else
      render json: { error: "Invalid or expired confirmation token." }, status: :unprocessable_entity
    end
  end

  def user_permissions
    if current_user
      permissions = {
        can_create_booking: can?(:create, Booking),
        can_view_own_bookings: can?(:read, Booking.new(user: current_user)), # Check if they can read a new booking associated with them
        can_update_any_own_booking: can?(:update, Booking.new(user: current_user)), # Check if they can update any booking associated with them
        can_delete_any_own_booking: can?(:destroy, Booking.new(user: current_user)), # Check if they can destroy any booking associated with them
        can_view_all_bookings: can?(:read, Booking),
      }
      render json: permissions
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current
    if current_user
      avatar_url = current_user.avatar.attached? ? url_for(current_user.avatar) : nil

      render json: {
        user_id: current_user.id,
        email: current_user.email,
        name: current_user.name,
        role: current_user.role,
        avatar_url: avatar_url # <--- Send the URL, not the object
      }
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
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
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
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
        @user.avatar.attach(params[:avatar])

        # Explicitly save the user to persist the attachment and trigger validations
        if @user.save # <--- ADD THIS LINE!
          Rails.logger.info "Avatar attached successfully? #{@user.avatar.attached?}"
          Rails.logger.info "User errors after save: #{@user.errors.full_messages if @user.errors.present?}"
          Rails.logger.info "Active Storage errors after save: #{@user.avatar.errors.full_messages if @user.avatar.errors.present?}"

          if @user.avatar.attached?
            render json: { avatar_url: url_for(@user.avatar) }, status: :ok
          else
            # This should ideally not be hit if @user.save was true, but good for robustness
            render json: {
              error: "Failed to attach avatar (post-save check)",
              details: @user.errors.full_messages + (@user.avatar.errors.full_messages if @user.avatar.errors.present? ).to_a
            }, status: :unprocessable_entity
          end
        else
          # If @user.save returns false (due to validation errors)
          render json: {
            error: "Failed to update user due to validation errors",
            details: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      else
        render json: { error: "No valid image uploaded or invalid file format" }, status: :bad_request
      end
    rescue ActiveStorage::IntegrityError => e
      Rails.logger.error "Integrity error: #{e.message}"
      Rails.logger.error "Blob key: #{@user.avatar.blob&.key}"
      raise
    end
  end

  def destroy_avatar
    # Check if an avatar is attached before attempting to purge
    if @user.avatar.attached?
      @user.avatar.purge # This deletes the file from S3 and the record from the database
      render json: { message: "Avatar successfully deleted" }, status: :ok
    else
      render json: { error: "No avatar to delete" }, status: :not_found
    end
  rescue => e
    # Catch any unexpected errors during deletion
    Rails.logger.error "Error deleting avatar for user #{@user.id}: #{e.message}"
    render json: { error: "Failed to delete avatar", details: e.message }, status: :internal_server_error
  end

  private

  def set_user
    @user = User.find(params[:id])
    unless @user == current_user # Assuming current_user is set by authenticate_user!
      render json: { error: "Unauthorized access" }, status: :unauthorized and return
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def avatar_params
    params.permit(:avatar)
  end
end
