class BestGuessAttempt < ActiveRecord::Base
  attr_accessor :joined

  before_validation :set_value, if: :best_guess

  after_create :discount_user_credits
  after_create :happens_at_to_best_guess, if: :tournament?
  before_destroy :rollback_user_credits, if: :tournament?

  belongs_to :user
  belongs_to :best_guess
  has_many :statement_answers, dependent: :destroy
  has_many :statements, through: :statement_answers

  accepts_nested_attributes_for :statement_answers

  validates :user, :best_guess, presence: true
  validates :user_id, uniqueness: { scope: :best_guess_id, message: 'Você já deu um palpite neste jogo' }
  validate :best_guess_is_active
  validate :user_have_credits, on: :create

  scope :finished, -> { where.not(finished_at: nil) }
  scope :with_correct_answers, -> (best_guess_id) { joins(:statements).where('"statement_answers"."value" = "statements"."answer" AND "statement_answers"."statement_id" = "statements"."id" AND "statements"."best_guess_id" = ?', best_guess_id).order('"best_guess_attempts"."score" DESC, "best_guess_attempts"."finished_at" - "best_guess_attempts"."started_at" ASC') }

  delegate :tournament?, to: :best_guess

  def finish_time
    finished_at && finished_at - started_at
  end

  def user_have_credits
    return true if user && user.credits > 0 && best_guess && user.credits >= best_guess.join_cost_in_credits
    errors.add(:base, :must_have_credits)
  end

  def set_value
    self.value_in_credits ||= best_guess.join_cost_in_credits
  end

  def best_guess_is_active
    return true if best_guess && best_guess.active?
    errors.add(:base, :is_not_active)
  end

  def discount_user_credits
    user.decrement!(:credits, value_in_credits) if user
  end

  def happens_at_to_best_guess
    if best_guess.best_guess_attempts.count == best_guess.players
      best_guess.happens_at = DateTime.now
      best_guess.ends_at = best_guess.duration_time.minutes.from_now
      best_guess.save(validate: false)
    end
  end

  private

  def rollback_user_credits
    user.increment!(:credits, value_in_credits) if user && tournament?
  end
end
