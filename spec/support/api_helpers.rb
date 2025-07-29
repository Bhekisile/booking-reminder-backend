module ApiHelpers
  def auth_header(token)
    { 'Authorization' => "Bearer #{token}" }
  end
end