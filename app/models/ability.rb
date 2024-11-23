class Ability
  include CanCan::Ability

  def initialize(current_user_role)
    if current_user_role == 'admin'
      can :manage, Category
      can :manage, Product
    else
      can :read, Category, status: true
      can :read, Product, status: true
    end
  end
end
