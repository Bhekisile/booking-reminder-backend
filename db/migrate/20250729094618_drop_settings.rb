class DropSettings < ActiveRecord::Migration[7.1]
  def change
    drop_table :settings, force: :cascade
  end
end
