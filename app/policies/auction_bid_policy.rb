class AuctionBidPolicy < ApplicationPolicy
  def create?
    user && record
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
