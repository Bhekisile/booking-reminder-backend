class Api::V1::OrganizationsController < ApplicationController
  # before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:create, :update]

  # Set the organization for show, update, and destroy actions
  before_action :set_organization, only: [:show, :update]

  # GET /api/v1/organizations
  def index
    @current_user ||= User.find_by(id: session[:user_id]) || User.find_by(id: request.headers['Authorization'])

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
    @current_user ||= User.find_by(id: organization_params[:user_id])

    if @current_user.organization.present?
      render json: { error: "You already belong to an organization." }, status: :forbidden
      return
    end

    @organization = Organization.new(organization_params.except(:user_id))
    if @organization.save
      current_user.update(organization: @organization) # associate user
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

  # GET /api/v1/organizations/:id
  def set_organization
    @organization = Organization.find_by(id: params[:id])
    unless @organization
      render json: { error: "Organization not found" }, status: :not_found
    end
  end
end
