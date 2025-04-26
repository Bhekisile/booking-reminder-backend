class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :surname, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.string :cellphone, null: false
      t.string :whatsapp
      t.string :email
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

