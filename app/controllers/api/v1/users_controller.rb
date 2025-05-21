class Api::V1::UsersController < ApplicationController
  include Devise::Controllers::Helpers

  before_action :authenticate_user!, only: [:update, :current, :destroy]
  before_action :set_user, only: [:update]

  # GET /api/v1/users
  def index
    @users = User.all
    render json: @users
  end

  def current
    if current_user
      render json: { user_id: current_user.id, email: current_user.email, name: current_user.name }
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end


  # GET /api/v1/users/1
  def show
    render json: @user
  end

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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
