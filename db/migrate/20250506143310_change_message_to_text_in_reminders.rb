class ChangeMessageToTextInReminders < ActiveRecord::Migration[7.1]
  def change
    change_column :reminders, :message, :text, null: false
  end
end
