class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :invitations, dependent: :destroy
end
