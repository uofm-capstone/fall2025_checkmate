# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md

    user ||= User.new(role: :guest) # Guest user (not logged in)

    if user.present?

      # Student abilities
      if user.student?
        can :read, Semester
        can :read, Team, user_teams: { user_id: user.id }
        can :read, Repository, team: { user_teams: { user_id: user.id } }
        can :read, Sprint
      end

      # TA abilities
      if user.ta?
        can :read, Semester
        can :read, Team
        can :create, Team
        can :update, Team
        can :manage, UserTeam
        can :read, Repository
        can :create, Repository
        can :update, Repository
        can :read, Sprint
        can :create, Sprint
        can :update, Sprint
      end

      # Admin abilities - can do everything
      if user.admin?
        can :manage, :all
      end

    end
  end
end
