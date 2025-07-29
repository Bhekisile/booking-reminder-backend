class RemoveSettingReferenceFromOrganizations < ActiveRecord::Migration[7.1]
  def change
    remove_reference :organizations, :setting, null: false, foreign_key: true
  end
end
