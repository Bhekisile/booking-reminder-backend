class AddEmailToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :email, :string
    add_column :organizations, :business_start, :datetime
    add_column :organizations, :business_end, :datetime
    add_column :organizations, :address1, :string
    add_column :organizations, :address2, :string
    add_column :organizations, :phone, :string
    add_reference :organizations, :user, null: false, foreign_key: true
  end
end
