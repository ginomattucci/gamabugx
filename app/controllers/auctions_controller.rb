class AuctionsController < ApplicationController
  def show
    @auction = Auction.find(params[:id])
    @highlight_last_bids = @auction.bids.includes(:user).order(created_at: :desc)
    @attempt = @auction.auction_attempts.where(user: current_user).last
  end

  def verify_status
    auction = Auction.find(params[:auction_id])
    auction.check_winner
    render nothing: true
  end
end
