class BestGuessesController < ApplicationController
  after_action :verify_authorized, except: %i(verify_status unfinished_attempt_redirect feedback)

  def show
    @best_guess = BestGuess.find(params[:id])
    authorize @best_guess
    @attempt = BestGuessAttempt.find_by(user: current_user, best_guess: @best_guess)
    @highlight_last_bids = @best_guess.best_guess_attempts
    @winner_attempt = BestGuessAttempt.find_by(user: @best_guess.winner, best_guess: @best_guess) if @best_guess.winner.present?
    @correct_awnsers = @best_guess.statements
  end

  def verify_status
    best_guess = BestGuess.find(params[:best_guess_id])
    best_guess.check_winner
    render nothing: true
  end

  def unfinished_attempt_redirect
    best_guess = BestGuess.find(params[:best_guess_id])
    redirect_to best_guess_path(best_guess), alert: 'O jogo acabou e seu palpite não foi contabilizado. Mais sorte da próxima vez.'
  end

  def feedback
    @best_guess = BestGuess.find(params[:best_guess_id])
    @correct_awnsers = @best_guess.statements
    @attempt = BestGuessAttempt.find_by(user: current_user, best_guess: @best_guess)
    @winner_attempt = BestGuessAttempt.find_by(user: @best_guess.winner, best_guess: @best_guess) if @best_guess.winner.present?
    render partial: 'feedback'
  end
end
