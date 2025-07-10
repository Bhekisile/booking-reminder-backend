class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.time :business_start, null: false
      t.time :business_end, null: false
      t.boolean :notification, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
