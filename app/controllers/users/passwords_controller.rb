class Users::PasswordsController < Devise::PasswordsController
  # 👇 Skip authentication requirement for token-based reset
  skip_before_action :require_no_authentication, only: [:edit]
  before_action :validate_token, only: [:edit, :update]

  def create
    user = User.find_by(email: params[:user][:email])
    user.reset_password_token = user.send(:set_reset_password_token) # Generate a token for the user
    user.reset_password_sent_at = Time.current
    if user
      UserMailer.reset_password_email(user).deliver_later
    end
    render json: { notice: "Check your email for reset instructions." }
  end
 
  def edit
    @user = User.find_by(email: params[:email])
    begin
      @token = params[:reset_password_token]
      User.find_signed!(@token, purpose: "password_reset")
      redirect_to "https://booking-reminder.expo.app/ResetPasswordScreen?token=#{@token}", allow_other_host: true
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render json: { error: "Token expired or invalid." }, status: :unauthorized
    end
  end

  def update
    @user = User.find_signed!(params[:reset_password_token], purpose: "password_reset")
    if @user.update(password_params)
      redirect_to login_path, notice: "Password has been reset succesfully. Please sign in."
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end

    rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "Token expired or invalid." }, status: :unauthorized
  end

  private

  # Add a new endpoint to validate tokens
  def validate_token
    begin
      token = params[:reset_password_token]
      user = User.find_signed!(token, purpose: "password_reset")
      render json: { valid: true, user_id: user.id }
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render json: { valid: false, error: "Token expired or invalid." }, status: :unauthorized
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end