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

  describe "POST /api/v1/emails/check (Postmark webhook)" do
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:payload) do
      {
        RecordType: "Bounce",
        MessageID: "883953f4-6105-42a2-a16a-77a8eac79483",
        Type: "HardBounce",
        TypeCode: 1,
        Name: "Hard bounce",
        Tag: "Invitation",
        MessageStream: "outbound",
        Description: "The server was unable to deliver your message (ex: unknown user, mailbox not found).",
        Email: "example@example.com",
        From: "sender@example.com",
        BouncedAt: "2023-01-01T12:00:00Z"
      }
    end

    it "accepts a valid webhook payload and returns 200 OK" do
      post "/api/v1/emails/check", params: payload.to_json, headers: headers

      expect(response).to have_http_status(:ok)
    end

    it "logs the webhook payload" do
      allow(Rails.logger).to receive(:info)

      post "/api/v1/emails/check", params: payload.to_json, headers: headers

      expect(Rails.logger).to have_received(:info).with(/Postmark webhook payload/)
    end

    it "handles invalid JSON gracefully" do
      post "/api/v1/emails/check", params: "invalid json", headers: headers

      expect(response).to have_http_status(:ok) # still return 200 so Postmark doesn’t retry forever
    end
  end
end
