class SubscriptionRequired
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Skip subscription check for certain paths
    excluded_paths = [
      '/api/v1/auth/',
      '/api/v1/subscriptions/',
      '/api/v1/payfast/',
      '/api/v1/users/trial_status'
    ]
    
    if excluded_paths.any? { |path| request.path.start_with?(path) }
      return @app.call(env)
    end

    # Extract user from token (assuming you have JWT authentication)
    token = request.get_header('HTTP_AUTHORIZATION')&.gsub('Bearer ', '')
    
    if token
      begin
        decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base)
        user_id = decoded_token[0]['user_id']
        user = User.find_by(id: user_id)
        
        if user && !user.has_active_subscription?
          return [
            403,
            { 'Content-Type' => 'application/json' },
            [{ error: 'Subscription required', trial_expired: true }.to_json]
          ]
        end
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        # Invalid token or user not found - let the main app handle it
      end
    end

    @app.call(env)
  end
end

# Add to config/application.rb:
# config.middleware.use SubscriptionRequired