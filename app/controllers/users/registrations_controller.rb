class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  respond_to :json

  before_action :configure_sign_up_params, only: [:create]

  def create
    @user = User.new(user_params)
    @user.admin = true if User.count == 0 # First user becomes admin

    if @user.save
      UserMailer.with(user: @user).welcome_email.deliver_later
      render json: { notice: "Account created!" }
    else
      Rails.logger.error "User creation failed: #{@user.errors.full_messages.join(', ')}"
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create_member
    Rails.logger.debug "Token param: #{member_params[:token]}"
    invitation = Invitation.find_by(token: member_params[:token])
    Rails.logger.debug "Invitation found: #{invitation.inspect}"

    if invitation.nil? || invitation.expired?
      Rails.logger.debug "Token invalid or expired"
      return render json: { error: 'Invalid or expired token' }, status: :unprocessable_entity
    end

    inviter = invitation.user
    user = User.new(member_params.except(:token))
    user.admin = true if inviter&.admin? # assign admin if inviter is admin
    
    user.save!

    UserMailer.with(user: user).welcome_email.deliver_later
    invitation.destroy
    render json: { message: 'Account created', user: user }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Member creation failed: #{e.message}"
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :organization_id)
  end

  def member_params
    params.require(:user).permit(:token, :name, :email, :password, :organization_id)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :organization_id])
  end

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(current_user, :user, request.headers['Authorization'])
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes].merge(token: token)
      }
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end