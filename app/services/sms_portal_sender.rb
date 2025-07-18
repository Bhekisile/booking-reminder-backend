require 'ostruct'
require 'net/http'
require 'uri'
require 'json'

class SmsPortalSender
  def self.send_sms(to:, message:)
    if Rails.env.test?
      Rails.logger.info("[Mock SMS] To: #{to} | Message: #{message}")
      OpenStruct.new(success?: true, mock: true)
    else
      uri = URI.parse(ENV["SMSP_URL"])

      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req.basic_auth(ENV["CLIENT_ID"], ENV["API_SECRET"])

      req.body = {
        messages: [
          {
            content: message,
            destination: to
          }
        ]
      }.to_json

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      unless res.is_a?(Net::HTTPSuccess)
        Rails.logger.error("SMSPortal Error: #{res.body}")
        raise "SMSPortal failed to send SMS"
      end

      res
    end
  end
end
