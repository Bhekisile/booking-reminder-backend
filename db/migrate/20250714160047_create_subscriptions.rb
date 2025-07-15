class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :active, default: false
      t.datetime :trial_ends_at
      t.datetime :subscribed_at
      t.timestamps
    end
  end
end
