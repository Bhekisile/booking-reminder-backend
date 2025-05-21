class AddAddressToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :name, :string
    add_column :settings, :address1, :string
    add_column :settings, :address2, :string
    add_column :settings, :phone, :string
    add_column :settings, :email, :string
  end
end
