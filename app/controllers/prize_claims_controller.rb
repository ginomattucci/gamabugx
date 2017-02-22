class PrizeClaimsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @games = Auction.claimable_by_winner(current_user) + BestGuess.claimable_by_winner(current_user)
    @prize_claims = policy_scope(PrizeClaim)
    authorize @prize_claims
  end

  def new
    if params[:best_guess_id]
      game = BestGuess.find(params[:best_guess_id])
    elsif params[:auction_id]
      game = Auction.find(params[:auction_id])
    end
    @prize_claim = PrizeClaim.new(target: game, user: current_user)
    authorize @prize_claim
  end

  def create
    model = params[:prize_claim][:target_type].camelize.constantize
    id    = params[:prize_claim][:target_id]
    game  = model.find(id)
    @prize_claim = PrizeClaim.new(permitted_params.merge(target: game, user: current_user))
    authorize @prize_claim

    if @prize_claim.save
      redirect_to prize_claims_path, notice: 'Revindicado com sucesso. Fique de olho em seu email, entraremos em contato por lá.'
    else
      render "new"
    end
  end

  private

  def permitted_params
    params.require(:prize_claim).permit(:full_name, :deliver_address, :cpf, :uf,
                                        :phone_number, :notes, :neighborhood,
                                        :city, :country, :zip_code)
  end
end
