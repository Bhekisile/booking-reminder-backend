class RemoveSubscriptionFieldsFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :paystack_customer_code, :string
    remove_column :users, :paystack_subscription_code, :string
    remove_column :users, :subscription_status, :string
  end
end
