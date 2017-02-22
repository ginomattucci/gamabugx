class AuctionPolicy < ApplicationPolicy
  def cancel_attempt?
    record.tournament? && record.happens_at.nil?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
