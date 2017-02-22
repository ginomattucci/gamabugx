class BestGuessDecorator < Draper::Decorator
  delegate_all

  def statements_have_image?
    statements.where.not(image: nil).exists?
  end

  def last_user
    best_guess_attempts.last.try(:user)
  end

  def last_username
    last_user.try(:username) || '---'
  end
end
