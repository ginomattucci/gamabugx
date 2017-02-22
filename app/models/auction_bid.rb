class AuctionBid < ActiveRecord::Base
  attr_accessor :blink

  before_validation :set_value, if: :auction

  after_save :refresh_auction
  before_save :discount_user_credits

  belongs_to :user
  belongs_to :auction
  belongs_to :auction_attempt

  validates :auction, :user, :value_in_credits, presence: true
  validate :user_have_credits
  validate :active_auction
  validate :avoid_duplicated_user_bid

  def refound
    user.increment!(:credits, value_in_credits)
    self.destroy
  end

  private

  def avoid_duplicated_user_bid
    return true if auction.nil? || user.nil?
    return true if auction.bids.select(:user_id).last.try(:user_id) != user.id
    errors.add(:base, :duplicate_bids)
  end

  def user_have_credits
    return true if user && user.credits > 0 && auction && user.credits >= auction.bid_cost_in_credits
    errors.add(:base, :must_have_credits)
  end

  def active_auction
    return true if auction && auction.reload && auction.ended_at.nil?
    errors.add(:base, :auction_finished)
  end

  def set_value
    self.value_in_credits ||= auction.bid_cost_in_credits
  end

  def refresh_auction
    auction.increment!(:final_cost, 0.01)
  end

  def discount_user_credits
    if auction.tournament?
      if auction_attempt
        auction_attempt.decrement!(:credits, value_in_credits)
        auction_attempt.reload
      end
    else
      user.decrement!(:credits, value_in_credits) if user
    end
  end
end
