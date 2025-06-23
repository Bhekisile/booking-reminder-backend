class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  authorize_resource class: false

  def index
    render json: { message: 'Welcome to the Admin Dashboard!' }
  end
end
