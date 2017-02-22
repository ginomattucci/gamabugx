class StatementAnswer < ActiveRecord::Base
  after_save :update_score

  belongs_to :best_guess_attempt
  belongs_to :statement

  validates :best_guess_attempt, :statement, presence: true

  scope :accurates, -> (id) { joins(:statement).where(statements: { best_guess_id: id }).where('"statements"."id" = "statement_answers"."statement_id" AND "statements"."answer" = "statement_answers"."value"') }

  def update_score
    best_guess_attempt.update(score: best_guess_attempt.statement_answers.accurates(best_guess_attempt.best_guess_id).count)
  end
end
