class FixOrganizationMembersTrialDates < ActiveRecord::Migration[7.1]
  def change
      # Clear trial dates for organization members (non-admin users in organizations)
      affected_users = User.joins(:organization)
                          .where(role: 'user')
                          .where.not(organization_id: nil)
      
      affected_count = affected_users.count
      
      affected_users.update_all(
        trial_start_date: nil,
        trial_end_date: nil,
        updated_at: Time.current
      )
      
      puts "Cleared trial dates for #{affected_count} organization members"
      
      # Optional: Clear subscription data for organization members since they should inherit from admin
      subscribed_members = User.joins(:organization)
                              .where(role: 'user')
                              .where.not(organization_id: nil)
                              .where(subscribed: true)
      
      subscription_count = subscribed_members.count
      
      if subscription_count > 0
        puts "Found #{subscription_count} subscribed organization members. Consider reviewing these manually."
        
        # Uncomment the next lines if you want to automatically clear subscription data
        subscribed_members.update_all(
          subscribed: false,
          subscription_status: 'trial',
          last_subscription_check: nil,
          updated_at: Time.current
        )
        puts "Cleared subscription data for #{subscription_count} organization members"
      end
    end
  end