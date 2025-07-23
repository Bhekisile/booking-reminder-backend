class Users::SessionsController < Devise::SessionsController
  before_action :authenticate_user!, only: [:destroy]

  include RackSessionsFix
  respond_to :json

  def create
    current_user = User.find_by(email: params[:user][:email])
    if current_user && current_user.valid_password?(params[:user][:password])
      if current_user.email_confirmed?
        sign_in current_user
        # Generate JWT token
        token = Warden::JWTAuth::UserEncoder.new.call(current_user, :user, request.headers['Authorization'])
        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: UserSerializer.new(current_user).serializable_hash[:data][:attributes].merge(token: token)
        }, status: :ok
      else
        render json: { error: 'Email not confirmed. Please check your inbox.' }, status: :unauthorized
      end
    else
      render json: { error: 'Invalid email or password.' }, status: :unauthorized
    end
  end

  private

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last,
      Rails.application.credentials.fetch(:secret_key_base)).first
      current_user = User.find(jwt_payload['sub'])
      # current_user = User.find_by(id: jwt_payload['sub'], jti: jwt_payload['jti'])
    end

    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end