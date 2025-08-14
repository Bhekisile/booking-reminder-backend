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
    self.reset_password_sent_at && self.reset_password_sent_at > 1.hours.ago
  end

  def reset_password(password)
    self.password = password
    self.reset_password_token = nil
    save!
  end

  def has_active_subscription?
    return true if subscribed?
    return trial_active?
  end

  def trial_active?
    return false unless trial_end_date
    Time.current < trial_end_date
  end

  def trial_days_remaining
    return 0 unless trial_active?
    ((trial_end_date - Time.current) / 1.day).ceil
  end

  def trial_status
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

  private

  def set_trial_dates
    self.trial_start_date = Time.current
    self.trial_end_date = Time.current + 3.months
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
