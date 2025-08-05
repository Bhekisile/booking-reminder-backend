class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.references :organization, null: false, foreign_key: true
      t.integer :inviter_id

      t.timestamps
    end
  end
end
