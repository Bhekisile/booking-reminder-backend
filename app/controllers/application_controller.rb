class ApplicationController < ActionController::API
  respond_to :json

  include ActionController::Flash
  include CanCan::ControllerAdditions
  include Devise::Controllers::Helpers # Ensure Devise helpers like current_user work


  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
  end

  def authenticate_admin!
    unless current_user&.role == 'admin'
      render json: { error: 'Admins only' }, status: :forbidden
    end
  end

  def authenticate_user!
    unless user_signed_in?
      render json: { error: 'You need to sign in or sign up before continuing' }, status: :unauthorized
    end
  end

  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar password password_confirmation current_password])
  end
end

