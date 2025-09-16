require 'net/http'
require 'json'


class Api::V1::EmailsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:check]
  
  def check
    email = params[:email]

    if email.blank?
      render json: { error: 'Email is required' }, status: :bad_request
      return
    end

    url = URI("https://api.rebound.postmarkapp.com/v1/check?email=#{email}&token=#{ENV['POSTMARK_REBOUND_TOKEN']}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")
    http.open_timeout = 5 # seconds
    http.read_timeout = 5 # seconds
    response = http.request(Net::HTTP::Get.new(url))

    if response.is_a?(Net::HTTPSuccess)
      render json: JSON.parse(response.body)
    else
      render json: { error: 'Unable to check email' }, status: :bad_gateway
    end
  end
end
