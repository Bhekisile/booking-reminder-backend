class AddSettingReferenceToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_reference :organizations, :setting, null: false, foreign_key: true
  end
end
