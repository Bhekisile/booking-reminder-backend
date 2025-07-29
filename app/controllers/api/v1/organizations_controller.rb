# app/controllers/api/v1/organizations_controller.rb
class Api::V1::OrganizationsController < ApplicationController
  # You might want to add authentication here, e.g., only admins can create organizations
  before_action :authenticate_user! # :authorize_admin!  Assuming an authorize_admin! method

  # GET /api/v1/organizations
  def index
    @organization = Organization.where(user_id: current_user.id)
    render json: @organization
  end

  # POST /api/v1/organizations
   def create
    @organization = Organization.new(organization_params)
    if @organization.save
      render json: @organization, status: :created
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  # GET /api/v1/organizations/:id
  def show
    @organization = Organization.find_by(id: params[:id])
    if @organization
      render json: @organization
    else
      render json: { error: "Organization not found" }, status: :not_found
    end
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update(organization_params)
      render json: @organization, status: :ok
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:business_start, :business_end, :name, :address1, :address2, :phone, :email, :user_id)
  end
end
