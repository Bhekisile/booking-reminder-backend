class AddNameToInvitations < ActiveRecord::Migration[7.1]
  def change
    add_column :invitations, :name, :string
  end
end
