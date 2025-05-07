class AddMessageTypeToReminders < ActiveRecord::Migration[7.1]
  def change
    add_column :reminders, :message_type, :string
  end
end
