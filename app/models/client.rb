class Client < ApplicationRecord
  belongs_to :user
  has_many :bookings, foreign_key: :client_id, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :surname, presence: true, length: { maximum: 255 }
  validates :cellphone, presence: true, length: { maximum: 10 }
end
