class AddSubscriptionFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :paystack_customer_code, :string
    add_column :users, :paystack_subscription_code, :string
    add_column :users, :subscription_status, :string
  end
end
