class Api::V1::OrganizationsController < ApplicationController
  before_action :authenticate_admin!, only: [:create, :update]
  before_action :set_organization, only: [:show, :update]

  # GET /api/v1/organizations
  def index
    organization = current_user.organization
    render json: organization || { message: "No organization assigned" }
  end

  # POST /api/v1/organizations
  def create
    organization = Organization.new(organization_params.except(:user_id))

    if organization.save
      current_user.update(organization: organization)
      render json: organization, status: :created
    else
      render json: organization.errors, status: :unprocessable_entity
    end
  end

  # GET /api/v1/organizations/:id
  def show
    if @organization
      render json: @organization
    else
      render json: { error: "Organization not found" }, status: :not_found
    end
  end

  def update
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

  def set_organization
    @organization = Organization.find_by(id: params[:id])
    unless @organization
      render json: { error: "Organization not found" }, status: :not_found
    end
  end
end

