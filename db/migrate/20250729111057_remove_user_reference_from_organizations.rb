class RemoveUserReferenceFromOrganizations < ActiveRecord::Migration[7.1]
  def change
    remove_reference :organizations, :user, null: false, foreign_key: true
  end
end
