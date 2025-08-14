class HomeController < ApplicationController
  # skip_before_action :authenticate_user!
  
  def index
    render html: "<h1>Welcome to the Booking App</h1>".html_safe
  end
end
