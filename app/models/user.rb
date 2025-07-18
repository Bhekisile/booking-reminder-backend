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
  has_one :subscription
  has_one_attached :avatar
  
  validates :name, presence: true, uniqueness: true
  
  enum role: { user: 'user', admin: 'admin' }
end
