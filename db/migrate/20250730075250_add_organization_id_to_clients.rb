class AddOrganizationIdToClients < ActiveRecord::Migration[7.1]
  def change
    add_reference :clients, :organization, foreign_key: true
  end
end
