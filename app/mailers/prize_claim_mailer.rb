class PrizeClaimMailer < ActionMailer::Base
  def notify_delivery(prize_claim)
    @prize_claim = prize_claim
    subject = "Seu prêmio foi enviado"
    mail(to: @prize_claim.user.email, subject: subject,
         from: "Faz Virar <contato@fazvirar.com.br>")
  end
end
