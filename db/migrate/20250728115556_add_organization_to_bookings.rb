class AddOrganizationToBookings < ActiveRecord::Migration[7.1]
  def change
    add_reference :bookings, :organization, foreign_key: true
  end
end
