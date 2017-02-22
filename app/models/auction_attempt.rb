class AuctionAttempt < ActiveRecord::Base
  belongs_to :auction
  belongs_to :user

  after_create :discount_user_credits
  after_create :set_auction_happens_at
  before_destroy :rollback_user_credits

  validates :auction, :user, :credits, presence: true

  private

  def discount_user_credits
    user.decrement!(:credits, auction.join_cost_in_credits) if user
  end

  def rollback_user_credits
    user.increment!(:credits, auction.join_cost_in_credits)
  end

  def set_auction_happens_at
    if auction.auction_attempts.count == auction.players
      auction.update(happens_at: DateTime.now)
    end
  end
end
