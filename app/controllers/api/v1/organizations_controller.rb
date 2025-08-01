# app/controllers/api/v1/organizations_controller.rb
class Api::V1::OrganizationsController < ApplicationController

  # GET /api/v1/organizations
  def index
    @organization = current_user.organization
    if @organization.nil?
      render json: { error: "You do not belong to an organization." }, status: :forbidden
      return
    else
      render json: @organization
    end
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
    params.require(:organization).permit(:business_start, :business_end, :name, :address1, :address2, :phone, :email)
  end
end
