class PagesController < ApplicationController
  def home
    @banners = Banner.all
    @highlight = Highlight.last.try(:target)
    if @highlight.is_a?(Auction)
      @highlight_last_bids = @highlight.bids.includes(:user).order(created_at: :desc)
    end
    @auctions = Auction.unfinished.non_highlighted.order(happens_at: :asc).limit(3)
    @best_guesses = BestGuess.active.non_highlighted.order(%q{
                                                          CASE WHEN "best_guesses"."tournament" IS TRUE THEN
                                                            CASE WHEN "best_guesses"."happens_at" IS NOT NULL THEN
                                                              CASE WHEN "best_guesses"."winner_id" IS NULL THEN
                                                                2
                                                              ELSE
                                                                3
                                                              END
                                                            ELSE
                                                              1
                                                            END
                                                          ELSE
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
                                                            END
                                                          END, "best_guesses"."id" ASC}).limit(3)
  end

  def contact
    @contact = Contact.new
  end

  def question
    @auction = Auction.first
  end

  def send_contact
    @contact = Contact.new(params.require(:contact).permit(:name, :email,
                                                          :subject, :message))
    if @contact.valid?
      ContactMailer.contact_mail(@contact).deliver_now
      redirect_to root_path, notice: 'Obrigado pelo contato, reponderemos em breve'
    else
      render :contact
    end
  end
end
