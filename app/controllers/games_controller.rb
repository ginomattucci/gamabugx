class GamesController < ApplicationController
  def index
    if params[:status] == 'active'
      @auctions = Auction.active
      @best_guesses = BestGuess.active
      @status = "ativo"
    else
      @auctions = Auction.none
      @best_guesses = BestGuess.none
      @status = "encontrado"
    end
  end

  def best_guesses
    @best_guesses = BestGuess.where(tournament: false).order(%q{
                                                        CASE WHEN "best_guesses"."winner_id" IS NULL THEN
                                                          CASE WHEN "best_guesses"."happens_at" <= NOW() AND "best_guesses"."ends_at" >= NOW() THEN
                                                            1
                                                          WHEN "best_guesses"."ends_at" <= NOW() THEN
                                                            4
                                                          ELSE
                                                            2
                                                          END
                                                        ELSE
                                                          3
                                                        END, "best_guesses"."id" ASC}).page(params[:page]).per(30)
  end

  def best_guess_tournaments
    @best_guesses = BestGuess.where(tournament: true).order(%q{CASE
                                                       WHEN "best_guesses"."happens_at" IS NOT NULL THEN
                                                        CASE WHEN "best_guesses"."winner_id" IS NULL THEN
                                                          CASE WHEN "best_guesses"."ends_at" <= NOW() THEN
                                                            4
                                                          ELSE
                                                            1
                                                          END
                                                        ELSE
                                                          3
                                                        END
                                                       ELSE
                                                         2
                                                       END, "best_guesses"."id" ASC}).page(params[:page]).per(30)
  end

  def auctions
    @auctions = Auction.where(tournament: false).order(%q{
                                                        CASE WHEN "auctions"."winner_id" IS NULL THEN
                                                          CASE WHEN "auctions"."ended_at" IS NULL THEN
                                                            CASE WHEN "auctions"."happens_at" IS NULL THEN
                                                              1
                                                            WHEN "auctions"."happens_at" <= NOW() THEN
                                                              1
                                                            ELSE
                                                              2
                                                            END
                                                          ELSE
                                                            4
                                                          END
                                                        ELSE
                                                          3
                                                        END, "auctions"."id" ASC
                                                       }).page(params[:page]).per(30)
  end

  def auction_tournaments
    @auctions = Auction.where(tournament: true).order(%q{CASE
                                                       WHEN "auctions"."happens_at" IS NOT NULL THEN
                                                        CASE WHEN "auctions"."winner_id" IS NULL THEN
                                                          CASE WHEN "auctions"."ended_at" IS NULL THEN
                                                            1
                                                          ELSE
                                                            4
                                                          END
                                                        ELSE
                                                          3
                                                        END
                                                       ELSE
                                                         2
                                                       END, "auctions"."id" ASC }).page(params[:page]).per(30)
  end
end
