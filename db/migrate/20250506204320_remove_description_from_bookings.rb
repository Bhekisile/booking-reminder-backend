class RemoveDescriptionFromBookings < ActiveRecord::Migration[7.1]
  def change
    remove_column :bookings, :description, :string, null: false
  end
end
