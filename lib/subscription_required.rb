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
      '/api/v1/users/trial_status',
      '/login',
      '/signup',
      '/api/v1/users/current'
    ]
    
    if excluded_paths.any? { |path| request.path.start_with?(path) }
      return @app.call(env)
    end

    # Extract user from token
    token = extract_token(request)
    
    if token
      user = decode_and_find_user(token)
      
      if user && !user_has_access?(user)
        Rails.logger.info "Subscription required for user: #{user.id} (organization: #{user.organization_id})"
        return [
          403,
          { 'Content-Type' => 'application/json' },
          [{ error: 'Subscription required', trial_expired: true }.to_json]
        ]
      end
    end

    @app.call(env)
  end

  private

  def user_has_access?(user)
    # If user belongs to an organization, check organization's subscription
    if user.organization_id.present?
      organization = user.organization
      return false unless organization
      
      # Find the admin user of this organization
      admin_user = organization.users.find_by(role: 'admin')
      return false unless admin_user
      
      # Check admin's subscription status
      return admin_user.has_active_subscription?
    else
      # For users without organization, check their own subscription
      return user.has_active_subscription?
    end
  end

  def extract_token(request)
    # Try Authorization header first
    auth_header = request.get_header('HTTP_AUTHORIZATION')
    return auth_header.gsub('Bearer ', '') if auth_header&.start_with?('Bearer ')
    
    # Fallback to token parameter
    request.params['token']
  end

  def decode_and_find_user(token)
    # Use the same secret key that's used in your authentication
    secret_key = Rails.application.credentials.secret_key_base || Rails.application.secrets.secret_key_base
    
    begin
      # Decode with additional verification
      decoded_token = JWT.decode(
        token, 
        secret_key, 
        true, 
        { 
          algorithm: 'HS256',
          verify_iat: true
        }
      )
      
      payload = decoded_token[0]
      Rails.logger.debug "Decoded token payload: #{payload.inspect}"
      
      user_id = payload['sub']
      Rails.logger.debug "Extracted user_id: #{user_id}"
      
      return nil unless user_id
      
      user = User.find_by(id: user_id)
      Rails.logger.debug "Found user: #{user&.id}"
      
      user
    rescue JWT::DecodeError => e
      Rails.logger.warn "JWT decode error: #{e.message}"
      nil
    rescue JWT::ExpiredSignature => e
      Rails.logger.warn "JWT expired: #{e.message}"
      nil
    rescue JWT::InvalidIatError => e
      Rails.logger.warn "JWT invalid iat: #{e.message}"
      nil
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "User not found: #{e.message}"
      nil
    rescue StandardError => e
      Rails.logger.error "Unexpected error in token decoding: #{e.class} - #{e.message}"
      nil
    end
  end
end
