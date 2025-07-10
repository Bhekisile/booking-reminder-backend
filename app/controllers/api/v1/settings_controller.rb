class Api::V1::SettingsController < ApplicationController
  def index
    @settings = Setting.all
    render json: @settings
  end

  def show
    render json: Setting.find(params[:id])
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
