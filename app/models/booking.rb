class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :client
  has_many :reminders, dependent: :destroy

  validates :client_id, presence: true

  # Add validations for the new structure
  validates :booked_date, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :client_id, presence: true
  validates :organization_id, presence: true
  validates :user_id, presence: true

  # Add scope for future bookings
  scope :upcoming, -> { where('booked_date >= ?', Time.current) }
  scope :past, -> { where('booked_date < ?', Time.current) }

  # Helper method to get formatted date time
  def formatted_datetime(timezone = nil)
    tz = timezone.presence || time_zone.presence || Time.zone.name
    booked_date.in_time_zone(tz).strftime("%d %b %Y at %H:%M")
  end
end
