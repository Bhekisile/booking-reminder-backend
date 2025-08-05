class User < ApplicationRecord
  before_create :confirmation_token
  include Devise::JWT::RevocationStrategies::JTIMatcher
    
  devise :database_authenticatable,
  :registerable,
  :recoverable,
  :rememberable,
  :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: self
  
  has_many :clients, dependent: :destroy
  has_many :bookings, dependent: :destroy # Users still have their own bookings, but these bookings will also be linked to an organization

  has_one :subscription
  has_one_attached :avatar

  belongs_to :organization, optional: true # A user might not belong to an organization initially, or ever

  validates :name, presence: true, uniqueness: true
  
  enum role: { user: 'user', admin: 'admin' }

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end

  def send_password_reset
    self.reset_password_token = generate_base64_token
    self.reset_password_sent_at = Time.current
    save!(:validate => false)
    UserMailer.reset_password_email(self, self.reset_password_token).deliver_later
  end

  def password_token_valid?
    self.reset_password_sent_at && self.reset_password_sent_at > 5.hours.ago
  end

  def reset_password(password)
    self.password = password
    self.reset_password_token = nil
    save!
  end

  private

  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

  def generate_base64_token
    test = SecureRandom.urlsafe_base64.to_s
  end
end
