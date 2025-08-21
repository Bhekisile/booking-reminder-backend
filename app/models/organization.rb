class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :invitations, dependent: :destroy

  MAX_USERS = 5

  validate :max_users_limit, on: :update

  def admin_user
    users.find_by(role: 'admin')
  end

  def regular_users
    users.where(role: 'user')
  end

  def user_count
    users.count
  end

  def can_add_user?
    user_count < MAX_USERS
  end

  def remaining_user_slots
    MAX_USERS - user_count
  end

  private

  def max_users_limit
    if users.count > MAX_USERS
      errors.add(:users, "cannot exceed #{MAX_USERS} users per organization")
    end
  end
end
