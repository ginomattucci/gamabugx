class AuctionBidsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :missing_credits

  def create
    create_attempt = false
    auction = Auction.find(params[:auction_id])

    if auction.tournament?
      attempt = AuctionAttempt.where(auction: auction, user: current_user).where('"auction_attempts"."credits" > 0').first
      if attempt.nil?
        attempt = AuctionAttempt.new(auction: auction, user: current_user,
                                     credits: auction.credits_by_attempt)
        authorize(attempt)
        auction.rebuy = AuctionAttempt.where(auction: auction, user: current_user).count > 0
        auction.joined = true
        create_attempt = true
      end
      attempt.save
      auction.reload
      GameNotification.publish(auction)
      if create_attempt
        return respond_to do |format|
          format.js { render nothing: true, status: :created }
          format.html { redirect_to (auction.rebuy ? :back : auction_path(auction)), notice: I18n.t('auction_bids.success') }
        end
      end
      if auction.happens_at.present?
        auction_bid = AuctionBid.new(user: current_user, auction: auction, auction_attempt: attempt, blink: true)
        authorize(auction_bid)
        if auction_bid.save
          GameNotification.publish(auction_bid)
          respond_to do |format|
            format.js { render nothing: true, status: :created }
            format.html { redirect_to auction_path(auction), notice: I18n.t('auction_bids.success') }
          end
        else
          errors = auction_bid.errors.full_messages
          if auction_bid.errors.full_messages == [I18n.t('auction_bids.missing_credits')]
            errors = [view_context.link_to(I18n.t('auction_bids.missing_credits'), plans_path)]
          end
          respond_to do |format|
            format.js { render json: { errors: errors }, status: :gone }
            format.html { redirect_to auction_path(auction), alert: I18n.t('auction_bids.fail') }
          end
        end
      else
        authorize(attempt)
        respond_to do |format|
          format.js { render nothing: true, status: :created }
          format.html { redirect_to auction_path(auction), notice: I18n.t('auction_bids.success') }
        end
      end
    else
      auction_bid = AuctionBid.new(user: current_user, auction: auction, auction_attempt: attempt, blink: true)
      authorize(auction_bid)
      if auction_bid.save
        GameNotification.publish(auction_bid)
        respond_to do |format|
          format.js { render nothing: true, status: :created }
          format.html { redirect_to auction_path(auction), notice: I18n.t('auction_bids.success') }
        end
      else
        errors = auction_bid.errors.full_messages
        if auction_bid.errors.full_messages == [I18n.t('auction_bids.missing_credits')]
          errors = [view_context.link_to(I18n.t('auction_bids.missing_credits'), plans_path)]
        end
        respond_to do |format|
          format.js { render json: { errors: errors }, status: :gone }
          format.html { redirect_to auction_path(auction), alert: I18n.t('auction_bids.fail') }
        end
      end
    end
  end


  private

  def missing_credits
    if request.xhr?
      render json: { errors: [link_to(I18n.t('auction_bids.missing_credits'), plans_path)] }, status: :payment_required
    else
      flash[:alert] = I18n.t('auction_bids.missing_credits')
      redirect_to(request.referrer || root_path)
    end
  end
end
