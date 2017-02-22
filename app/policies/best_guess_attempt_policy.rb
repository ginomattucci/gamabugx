class BestGuessAttemptPolicy < ApplicationPolicy
  def create?
    user_owner_of_attempt? && (record.best_guess.tournament? ? tournament_not_full? : user_have_credits?)
  end

  def edit?
    user && record.user == user && record.finished_at.nil? && record.best_guess.happens_at
  end

  def update?
    edit?
  end

  def first_attempt?
    user.best_guess_attempts.where(best_guess: record.best_guess).blank?
  end

  def join?
    create? && first_attempt?
  end

  def destroy?
    user && record && record.tournament? && record.best_guess.best_guess_attempts.count < record.best_guess.players
  end

  def user_owner_of_attempt?
    record && user && record.user == user
  end

  def tournament_not_full?
    record.best_guess.tournament? && user_have_credits? && record.best_guess.best_guess_attempts.count < record.best_guess.players
  end

  def user_have_credits?
    user.credits >= record.best_guess.join_cost_in_credits
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
