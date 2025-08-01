class Reminder < ApplicationRecord
  belongs_to :booking
  belongs_to :client, optional: true
  belongs_to :organization, optional: true
end
