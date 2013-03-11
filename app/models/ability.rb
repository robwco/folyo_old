# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.is_a? Admin
      can :manage, :all

    elsif user.is_a? Designer
      if user.accepted?
        can :read, Client
        can :manage, DesignerPost
      end
      can :read, Designer do |designer|
        designer.public?
      end
      can :manage, Designer do |designer|
        designer.id == user.id
      end

    elsif user.is_a? Client
      can :read, DesignerPost
      can :manage, Client do |client|
        client.id == user.id
      end
      can :read, Designer

    else
      can :read, Designer do |designer|
        designer.public? && designer.accepted?
      end
      can :map, Designer
    end

  end

end
