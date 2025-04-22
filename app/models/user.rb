class User < ApplicationRecord
  has_many :clients, dependent: :destroy
  has_one :setting, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
