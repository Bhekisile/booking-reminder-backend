require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user1) { User.create(name: 'Bheki', email: "test@example.com", password: "password", password_confirmation: "password") }
  let(:user2) { User.create(name: 'John', email: "john@example.com", password: "password", password_confirmation: "password") }
  let(:auth_token) { "valid_token" }

  # before do
  #   visit new_user_session_path
  #   fill_in "Email", with: user1.email
  #   fill_in "Password", with: user1.password
  #   click_button "Sign in"
  # end
  
  describe "GET /api/v1/users" do
    it "does not allow user to access another user's profile" do
      token = login_as(user1) # helper to get JWT

      get "/api/v1/users/#{user2.id}", headers: { "Authorization" => "Bearer #{auth_token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end