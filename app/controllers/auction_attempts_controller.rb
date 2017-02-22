class AuctionAttemptsController < ApplicationController
  def destroy
    auction_attempt = AuctionAttempt.find(params[:id])
    authorize(auction_attempt)
    auction = auction_attempt.auction
    auction_attempt.destroy
    auction.joined = true
    GameNotification.publish(auction)
    redirect_to root_path, notice: 'Sucesso'
  end
end
