class Users::PasswordsController < Devise::PasswordsController
  # 👇 Skip authentication requirement for token-based reset
  skip_before_action :require_no_authentication, only: [:edit]
  before_action :validate_token, only: [:edit, :update]

  def create
    user = User.find_by(email: params[:user][:email])
    if user
      user.send_password_reset
    end
    render json: { notice: "Check your email for reset instructions." }
  end
 
  # def edit
  #   user = User.find_by(reset_password_token: params[:token], email: params[:email])
  #   begin
  #     if user.present? && user.password_token_valid?
  #       if user.reset_password(params[:user][:password])
  #         @token = params[:reset_password_token]
  #         User.find_signed!(@token, purpose: "password_reset")
  #         redirect_to "https://booking-reminder.expo.app/ResetPasswordScreen?token=#{@token}", allow_other_host: true
  #       end
  #     end
  #   rescue ActiveSupport::MessageVerifier::InvalidSignature
  #     render json: { error: "Token expired or invalid." }, status: :unauthorized
  #   end
  # end

  def update
    user = User.find_by(reset_password_token: params[:reset_password_token], email: params[:email])
    if user.present? && user.password_token_valid?
      if user.reset_password(params[:user][:password])
        render json: { notice: "Password has been reset successfully." }
      else
        render json: { error: "Failed to reset password. Please try again." }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid or expired reset token." }, status: :unprocessable_entity
    end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "Token expired or invalid." }, status: :unauthorized
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end