class AuctionMailer < ActionMailer::Base
  def canceled_game(auction, user)
    @auction = auction
    @user = user
    subject = "Um jogo em que você deu lance foi cancelado"
    mail(to: user.email, subject: subject,
         from: "FazVirar <contato@fazvirar.com.br>")
  end
end
