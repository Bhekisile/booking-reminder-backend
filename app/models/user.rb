class User < ApplicationRecord
  before_create :confirmation_token
  before_create :set_trial_dates
  include Devise::JWT::RevocationStrategies::JTIMatcher
    
  devise :database_authenticatable,
  :registerable,
  :recoverable,
  :rememberable,
  :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :clients, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_one :subscription
  has_one_attached :avatar
  belongs_to :organization, optional: true

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
    self.reset_password_sent_at && self.reset_password_sent_at > 1.hours.ago
  end

  def reset_password(password)
    self.password = password
    self.reset_password_token = nil
    save!
  end

  def has_active_subscription?
    # If user belongs to an organization, check admin's subscription
    if organization_id.present?
      admin_user = organization&.users&.find_by(role: 'admin')
      return false unless admin_user
      
      # Check admin's subscription or trial
      return admin_user.subscribed? || admin_user.trial_active?
    else
      # For standalone users (admins without organization or independent users)
      return subscribed? || trial_active?
    end
  end

  def trial_active?
    return false unless trial_end_date
    Time.current < trial_end_date
  end

  def trial_days_remaining
    # For organization members, check admin's trial
    if organization_id.present? && role != 'admin'
      admin_user = organization&.users&.find_by(role: 'admin')
      return admin_user&.trial_days_remaining || 0
    end
    
    return 0 unless trial_active?
    ((trial_end_date - Time.current) / 1.day).ceil
  end

  def trial_status
    # For organization members, check admin's status
    if organization_id.present? && role != 'admin'
      admin_user = organization&.users&.find_by(role: 'admin')
      return admin_user&.trial_status || 'expired'
    end
    
    if subscribed?
      'subscribed'
    elsif trial_active?
      days_remaining = trial_days_remaining
      if days_remaining <= 3
        'expiring_soon'
      elsif days_remaining <= 7
        'expiring_this_week'
      elsif days_remaining <= 30
        'expiring_this_month'
      else
        'active'
      end
    else
      'expired'
    end
  end

  def subscription_required?
    !has_active_subscription?
  end

  def can_access_feature?(feature)
    case feature
    when :basic_features
      true # Always available
    when :premium_features
      has_active_subscription?
    when :unlimited_bookings
      has_active_subscription?
    else
      has_active_subscription?
    end
  end

  def subscribed?
    # For organization members, check if admin is subscribed
    if organization_id.present? && role != 'admin'
      admin_user = organization&.users&.find_by(role: 'admin')
      return admin_user&.subscribed? || false
    end
    
    # For admins or standalone users, check the subscribed field
    subscribed || false
  end


  def subscription_status
    # For organization members, return admin's subscription status
    if organization_id.present? && role != 'admin'
      admin_user = organization&.users&.find_by(role: 'admin')
      return admin_user&.subscription_status || 'inactive'
    end
    
    # For admins or standalone users, return their subscription status
    super || 'inactive'
  end

  private

  def set_trial_dates
    # Only set trial dates for admin users or users without organization
    if role == 'admin' || organization_id.blank?
      self.trial_start_date = Time.current
      self.trial_end_date = Time.current + 3.months
    end
  end

  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

  def generate_base64_token
    test = SecureRandom.urlsafe_base64.to_s
  end
end
