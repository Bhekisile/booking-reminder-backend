class SettingsController < ApplicationController
  def index
    render json: Setting.all
  end

  def show
    render json: Setting.find(params[:id])
  end
end
