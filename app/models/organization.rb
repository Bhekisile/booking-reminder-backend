class Organization < ApplicationRecord
  has_many :users
  has_many :bookings
  has_many :clients

  # You might also want to validate the uniqueness of the name if it's derived from setting name
  validates :name, presence: true, uniqueness: true
end
