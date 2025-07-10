class Booking < ApplicationRecord
  belongs_to :client
  has_many :reminders, dependent: :destroy

  validates :time, presence: true
  validates :date, presence: true
  validates :client_id, presence: true
end
