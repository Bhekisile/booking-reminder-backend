class AddExpiresAtToInvitations < ActiveRecord::Migration[7.1]
  def change
    add_column :invitations, :expires_at, :datetime
  end
end
