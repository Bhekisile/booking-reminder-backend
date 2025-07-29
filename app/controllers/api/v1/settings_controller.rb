class Api::V1::SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @settings = Setting.where(user_id: current_user.id)
    render json: @settings
  end

  def show
    render json: @setting
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      render json: @setting, status: :created
    else
      render json: @setting.errors, status: :unprocessable_entity
    end
  end

  def update
    unless current_user.organization
      return
    end

    @setting = Setting.find(params[:id])
    if @setting.update(setting_params)
      render json: @setting, status: :ok
    else
      render json: @setting.errors, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:business_start, :business_end, :name, :address1, :address2, :phone, :email, :user_id)
  end
end
