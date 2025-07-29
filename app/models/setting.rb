class Setting < ApplicationRecord
  belongs_to :user, dependent: :destroy
  # has_one :organization, dependent: :destroy
end
