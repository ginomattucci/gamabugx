class BestGuess < ActiveRecord::Base
  before_create :clear_happens_at, if: :tournament?

  belongs_to :winner, class_name: "User"
  has_many :statements, dependent: :nullify
  has_many :best_guess_attempts
  has_many :highlights, as: :target
  has_one :prize_claim, as: :target

  validates :title, :image, :description_url, :increase_value,
            :join_cost_in_credits, :question, :market_price, presence: true
  validates :happens_at, :ends_at, presence: true, unless: :tournament?
  validates :players, :duration_time, presence: true, if: :tournament?
  validates :description_url, format: { with: /\Ahttps?:\/\/.+\..+\z/ }
  validates :statements, length: { minimum: 1  }

  mount_uploader :image, ImageUploader
  mount_uploader :second_image, ImageUploader

  accepts_nested_attributes_for :statements, allow_destroy: true

  just_define_datetime_picker :happens_at
  just_define_datetime_picker :ends_at

  scope :active, -> { where(winner_id: nil).where('("best_guesses"."tournament" IS TRUE AND "best_guesses"."happens_at" IS NULL) OR ("best_guesses"."tournament" IS FALSE AND ("best_guesses"."happens_at" < :now AND "best_guesses"."ends_at" > :now) OR "best_guesses"."happens_at" > :now AND "best_guesses"."ends_at" > :now)', now: Time.now) }
  scope :scheduled, -> { where(winner_id: nil).where('("best_guesses"."tournament" IS TRUE AND "best_guesses"."happens_at" IS NULL) OR ("best_guesses"."tournament" IS FALSE AND "best_guesses"."happens_at" > :now AND "best_guesses"."ends_at" > :now)', now: Time.now) }
  scope :sold, -> { where.not(winner_id: nil).where('("best_guesses"."tournament" IS TRUE AND "best_guesses"."happens_at" IS NOT NULL) OR ("best_guesses"."tournament" IS FALSE AND "best_guesses"."happens_at" < :now AND "best_guesses"."ends_at" < :now)', now: Time.now) }
  scope :ended, -> { where(winner_id: nil).where('"best_guesses"."ends_at" < ?', Time.now) }
  scope :non_highlighted, -> { eager_load(:highlights).where(highlights: {target_id: nil})}
  scope :claimable_by_winner, -> (winner) { eager_load(:prize_claim).where(prize_claims: {target_id: nil}, winner: winner).where('ends_at > :deadline', deadline: claim_deadline)}

  def check_winner
    if finished? && winner.nil?
      valid_guesses = best_guess_attempts.finished.with_correct_answers(id).to_a.uniq
      if valid_guesses[0]
        if update(winner: valid_guesses[0].user, final_cost: partial_value.to_d / 100)
          BestGuessMailer.notify_winner(self).deliver_now
        end
      end
      GameNotification.publish(self)
    end
    winner
  end

  def discount_percentage
    (100 - (((final_cost/market_price) * 100))).floor
  end

  def active?
    (happens_at && happens_at.past? && ends_at > Time.now) || (tournament? && players > best_guess_attempts.count)
  end

  def finished?
    ends_at && ends_at <= 1.second.from_now
  end

  def sold?
    finished? && winner && final_cost > 0
  end

  def claimable?
    sold? && ends_at > self.class.claim_deadline
  end

  def scheduled?
    (happens_at && happens_at > Time.now) || (tournament? && happens_at.nil?)
  end

  def partial_value
    best_guess_attempts.count * increase_value
  end

  def self.search(query)
    where("title @@ ?", "#{query}")
  end

  def self.claim_deadline
    7.days.ago
  end

  def clear_happens_at
    self.happens_at = nil
  end
end
