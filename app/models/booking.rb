class Booking < ApplicationRecord
  belongs_to :client

  validates :time, presence: true
  validates :date, presence: true
  validates :client_id, presence: true
end
