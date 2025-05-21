class RemoveNotificationFromSettings < ActiveRecord::Migration[7.1]
  def change
    remove_column :settings, :notification
  end
end
