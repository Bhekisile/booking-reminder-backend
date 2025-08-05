class Invitation < ApplicationRecord
  before_create :generate_token_and_expiry
  
  belongs_to :organization
  belongs_to :inviter, class_name: 'User'

  validates :email, presence: true

  def expired?
    expires_at && Time.current > expires_at
  end

  private

  def generate_token_and_expiry
    self.token = SecureRandom.hex(10)
    self.expires_at = 7.days.from_now
  end
end
