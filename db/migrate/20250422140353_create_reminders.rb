class CreateReminders < ActiveRecord::Migration[7.1]
  def change
    create_table :reminders do |t|
      t.datetime :remind_at, null: false
      t.string :message, null: false
      t.references :booking, null: false, foreign_key: true

      t.timestamps
    end
  end
end
