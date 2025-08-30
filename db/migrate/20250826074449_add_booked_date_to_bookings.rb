class AddBookedDateToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :booked_date, :datetime
  end
end
