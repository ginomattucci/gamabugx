class AuctionDecorator < Draper::Decorator
  delegate_all

  def last_bidder
    bids.any? ? bids.last.user.try(:username) : '---'
  end
end
