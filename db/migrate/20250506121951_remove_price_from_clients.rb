class RemovePriceFromClients < ActiveRecord::Migration[7.1]
  def change
    remove_column :clients, :price, :decimal, precision: 8, scale: 2, null: false
  end
end
rails