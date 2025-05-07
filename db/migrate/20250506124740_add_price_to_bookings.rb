class AddPriceToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :price, :decimal
    add_column :bookings, :notes, :text
    add_column :bookings, :reminder, :boolean, default: false
  end
end
