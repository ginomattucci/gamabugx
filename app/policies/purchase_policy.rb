class PurchasePolicy < ApplicationPolicy
  def index?
    user
  end

  def create?
    user && user.has_complete_profile?
  end

  def success?
    user == record.user
  end

  class Scope < Scope
    def resolve
      if user
        scope.where(user: user)
      else
        scope.none
      end
    end
  end
end
