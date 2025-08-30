class RemoveDateAndTimeFromBookings < ActiveRecord::Migration[7.1]
  def change
    remove_column :bookings, :date, :datetime
    remove_column :bookings, :time, :datetime
  end
end
