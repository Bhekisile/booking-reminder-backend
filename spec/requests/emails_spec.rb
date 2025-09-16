require 'rails_helper'

RSpec.describe "Emails API", type: :request do
  describe "GET /api/v1/emails/check" do
    let(:email) { "test@example.com" }
    let(:api_url) { "https://api.rebound.postmarkapp.com/v1/check?email=#{email}&token=#{ENV['POSTMARK_REBOUND_TOKEN']}" }

    context "when email is provided" do
      before do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: { result: "risky", reason: "Mailbox does not exist" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns the response from Postmark" do
        get "/api/v1/emails/check", params: { email: email }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["result"]).to eq("risky")
        expect(json["reason"]).to eq("Mailbox does not exist")
      end
    end

    context "when email is missing" do
      it "returns a bad request" do
        get "/api/v1/emails/check"

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email is required")
      end
    end

    context "when Postmark returns an error" do
      before do
        stub_request(:get, api_url)
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "returns a bad gateway error" do
        get "/api/v1/emails/check", params: { email: email }

        expect(response).to have_http_status(:bad_gateway)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unable to check email")
      end
    end
  end
end
