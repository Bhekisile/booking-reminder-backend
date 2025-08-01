# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.admin?
      can :manage, :all # Full access for admins
    else
      # Regular users
      can :read, :all # Allow basic reads if needed
      can [:create, :update, :destroy], User, id: user.id # Can only update or delete themselves
      # Define more permissions if you have other models
      can [:create, :destroy, :update], Booking, id: user.id # Allow users to create and destroy their own bookings
      can :read, Booking # Allow users to read bookings
      #       can :manage, Booking, user_id: user.id
      # can :access, :premium_feature if user.subscription_status == 'active'
    end
  end
end
