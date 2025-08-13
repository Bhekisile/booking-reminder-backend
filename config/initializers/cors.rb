# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from any origin
    # This is useful for development, but in production, you should specify the allowed origins.
    # For example, to allow requests from 'https://example.com':
    # origins '*', 'https://booking-reminder--9dwucrrg1r.expo.app/', 'https://booking-reminder.expo.app'
    origins "https://booking-reminder--9dwucrrg1r.expo.app/"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization']
  end
end
