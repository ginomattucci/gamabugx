class PrizeClaimPolicy < ApplicationPolicy
  def index?
    user
  end

  def new?
    record.target.claimable? && record.target.winner == record.user && !record.target.prize_claim
  end

  def create?
    new?
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
