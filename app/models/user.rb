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
  has_one :setting, dependent: :destroy
  has_one :subscription
  has_one_attached :avatar
  
  validates :name, presence: true, uniqueness: true
  
  enum role: { user: 'user', admin: 'admin' }

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end

  private

  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end
end
