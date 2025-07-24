class HomeController < ApplicationController
  def index
    render html: "<h1>Welcome to the Booking App</h1>".html_safe
  end
end
