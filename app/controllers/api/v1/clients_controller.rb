class Api::V1::ClientsController < ApplicationController
  def index
    render json: Client.all
  end

  def show
    render json: Client.find(params[:id])
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      render json: @client, status: :created
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      render json: @client, status: :ok
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @client = Client.find(params[:id])
    if @client.destroy
      render json: { message: 'Client deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete client' }, status: :unprocessable_entity
    end
  end

  private
  
  def client_params
    params.require(:client).permit(:name, :surname, :cellphone, :whatsapp, :email, :user_id)
  end
end
