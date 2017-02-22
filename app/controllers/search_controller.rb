class SearchController < ApplicationController
  def games
    query = params[:search][:query]
    @auctions = Auction.search(query)
    @best_guesses = BestGuess.search(query)
  end
end
