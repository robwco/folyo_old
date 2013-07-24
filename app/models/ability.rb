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
        can :create, DesignerReply
        can :manage, DesignerPost
      end
      can [:history, :archives], JobOffer
      can [:read, :map, :san_francisco_bay_area], Designer do |designer|
        designer.public?
      end
      can :manage, Designer do |designer|
        designer.id == user.id
      end
      can :read, JobOffer

    elsif user.is_a? Client
      can :read, DesignerPost
      can [:read, :pick], DesignerReply
      can :update_pick, DesignerReply do |reply|
        reply.job_offer.client_id == user.id
      end
      can :manage, Client do |client|
        client.id == user.id
      end
      can [:read, :create], JobOffer
      can :manage, JobOffer do |job_offer|
        job_offer.client_id == user.id
      end
      can :create, Order
      can [:read, :confirm, :checkout], Order do |order|
        order.job_offer.client_id == user.id
      end
      can [:read, :map, :san_francisco_bay_area], Designer

    else
      can :read, Designer do |designer|
        designer.public? && designer.accepted?
      end
      can [:map, :san_francisco_bay_area], Designer
    end

  end

end
