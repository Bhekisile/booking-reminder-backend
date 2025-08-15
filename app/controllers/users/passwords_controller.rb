class Users::PasswordsController < Devise::PasswordsController
  before_action :strip_email_param, only: :create
  # 👇 Skip authentication requirement for token-based reset
  # skip_before_action :authenticate_user!

  def create
    user = User.find_by(email: params[:user][:email])
    if user
      user.send_password_reset
    end
    render json: { notice: "Check your email for reset instructions." }
  end
  
  def update
    # Get the token from the correct nested structure
    user_params = params[:user] || params.dig(:password, :user)
    reset_token = user_params&.dig(:reset_password_token)
    
    if reset_token.blank?
      return render json: { error: "Reset token is required." }, status: :bad_request
    end

    # Find user by reset_password_token only (no email needed)
    user = User.find_by(reset_password_token: reset_token)
    
    if user.blank?
      return render json: { error: "Invalid reset token." }, status: :unprocessable_entity
    end

    unless user.password_token_valid?
      return render json: { error: "Reset token has expired." }, status: :unprocessable_entity
    end

    # Use the password from user_params
    if user.reset_password(user_params[:password])
      render json: { notice: "Password has been reset successfully." }
    else
      render json: { 
        error: "Failed to reset password.", 
        details: user.errors.full_messages 
      }, status: :unprocessable_entity
    end
    
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "Token expired or invalid." }, status: :unauthorized
  rescue StandardError => e
    Rails.logger.error "Password reset error: #{e.message}"
    render json: { error: "An error occurred. Please try again." }, status: :internal_server_error
  end

  private

  def strip_email_param
    params[:user][:email] = params[:user][:email].strip if params[:user] && params[:user][:email]
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def update_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end
end