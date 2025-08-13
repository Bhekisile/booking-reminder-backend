class AddTrialFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :trial_start_date, :datetime
    add_column :users, :trial_end_date, :datetime
    add_column :users, :subscribed, :boolean, default: false
    add_column :users, :subscription_status, :string, default: 'trial'
    add_column :users, :last_subscription_check, :datetime
    
    # Set trial dates for existing users
    User.find_each do |user|
      if user.trial_start_date.nil?
        user.update(
          trial_start_date: user.created_at,
          trial_end_date: user.created_at + 3.months
        )
      end
    end
  end
end
