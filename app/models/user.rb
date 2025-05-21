class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable,
         :registerable,
          :recoverable,
          :rememberable,
          :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
         
  has_many :clients, dependent: :destroy
  has_one :setting, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
  validates :password_confirmation, presence: true
end
