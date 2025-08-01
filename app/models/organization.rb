class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :invitations, dependent: :destroy

  # You might also want to validate the uniqueness of the name if it's derived from setting name
  # validates :name, presence: true, uniqueness: true
end
