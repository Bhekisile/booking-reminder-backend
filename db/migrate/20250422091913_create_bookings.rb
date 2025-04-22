class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.time :time, null: false
      t.date :date, null: false
      t.string :description, null: false
      t.boolean :payment, default: false, null: false
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
