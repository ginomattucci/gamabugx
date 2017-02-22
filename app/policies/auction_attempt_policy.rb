class AuctionAttemptPolicy < ApplicationPolicy
  def create?
    user_and_auction? && (tournament_number_of_players? || regular_auction_credits?)
  end

  def destroy?
    user && record && AuctionPolicy.new(user, record.auction).cancel_attempt?
  end

  def user_and_auction?
    user && record && record.auction
  end

  def tournament_number_of_players?
    record.auction.tournament? &&
      user.credits >= record.auction.join_cost_in_credits &&
      user_can_rebuy_or_number_of_players? &&
      record.auction.max_attempts > record.auction.auction_attempts.select('DISTINCT "auction_attempts"."user_id"').where(user: user).count
  end

  def regular_auction_credits?
    !record.auction.tournament? && user.credits > record.auction.bid_cost_in_credits
  end

  def user_can_rebuy_or_number_of_players?
    record.auction.happens_at.nil? ? number_of_players? : user_have_attempt?
  end

  def number_of_players?
    record.auction.auction_attempts.count < record.auction.players
  end

  def user_have_attempt?
    record.auction.auction_attempts.where(user: user).exists?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
