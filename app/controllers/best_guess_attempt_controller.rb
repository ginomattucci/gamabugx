class BestGuessAttemptController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: %i(edit update create)

  rescue_from Pundit::NotAuthorizedError, with: :missing_credits

  def create
    best_guess = BestGuess.find(params[:best_guess_id])
    attempt = BestGuessAttempt.new(user: current_user, best_guess: best_guess)
    if !BestGuessAttemptPolicy.new(current_user, attempt).user_have_credits?
      return redirect_to best_guess_path(best_guess), flash: { alert: I18n.t('activerecord.errors.models.auction_bid.attributes.base.must_have_credits') }
    end
    if best_guess.tournament?
      if BestGuessAttemptPolicy.new(current_user, attempt).tournament_not_full?
        authorize(attempt)
      else
        return redirect_to best_guess_path(best_guess), flash: { alert: 'Torneio já começou' }
      end
    else
      authorize(attempt)
    end
    if attempt.save
      attempt.joined = true
      GameNotification.publish(attempt)
      if best_guess.tournament?
        return redirect_to best_guess_path(best_guess)
      else
        return redirect_to best_guess_path(best_guess), flash: { notice: 'Inscrito com sucesso! Clique em START para começar seu palpite' }
      end
    else
      return redirect_to best_guess_path(best_guess), flash: { alert: attempt.errors.messages.values.join('; ') }
    end
  end

  def edit
    @best_guess = BestGuess.find(params[:best_guess_id])
    @attempt = BestGuessAttempt.find(params[:id])
    if policy(@attempt).edit?
      authorize(@attempt)
    else
      redirect_to best_guess_path(@best_guess), flash: { alert: 'Não autorizado' }
    end
    @attempt.started_at ||= DateTime.now
    @attempt.save
    @attempt.reload
    @statements = @best_guess.statements.shuffle
    @statements.each do |statement|
      @attempt.statement_answers.build(statement: statement)
    end
  end

  def update
    @best_guess = BestGuess.find(params[:best_guess_id])
    @attempt = BestGuessAttempt.find(params[:id])
    if policy(@attempt).update?
      authorize(@attempt)
    else
      redirect_to best_guess_path(@best_guess), flash: { alert: 'Não autorizado' }
    end
    if @attempt.update_attributes(permitted_params.merge(finished_at: Time.now))
      GameNotification.publish(@attempt)
      redirect_to best_guess_path(@best_guess)
    else
      render :edit
    end
  end


  def destroy
    best_guess = BestGuess.find(params[:best_guess_id])
    attempt = BestGuessAttempt.find(params[:id])
    authorize(attempt)
    if attempt.destroy
      GameNotification.publish(attempt)
    end
    redirect_to root_path
  end

  private

  def permitted_params
    params.require(:best_guess_attempt).permit(statement_answers_attributes: [:statement_id, :value])
  end

  def missing_credits
    if request.xhr?
      render json: { errors: [I18n.t('best_guesses.missing_credits')] }, status: :payment_required
    else
      flash[:alert] = I18n.t('best_guesses.missing_credits')
      redirect_to(request.referrer || root_path)
    end
  end
end
