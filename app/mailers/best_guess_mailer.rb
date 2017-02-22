class BestGuessMailer < ActionMailer::Base
  def notify_winner(best_guess)
    @best_guess = best_guess
    subject = "Você fez o melhor Super Palpite! Reivindique seu prêmio."
    mail(to: @best_guess.winner.email, subject: subject,
         from: "Faz Virar <contato@fazvirar.com.br>")
  end
end
