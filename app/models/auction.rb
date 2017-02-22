class Auction < ActiveRecord::Base
  before_create :clear_happens_at, if: :tournament?

  attr_accessor :reactivate, :joined, :rebuy

  belongs_to :winner, class_name: "User"
  has_many :bids, dependent: :nullify, class_name: "AuctionBid"
  has_many :users, -> { distinct }, through: :bids
  has_many :highlights, as: :target
  has_many :auction_attempts, dependent: :nullify
  has_one :prize_claim, as: :target

  validates :title, :image, :description_url,
            :bid_cost_in_credits, :market_price, presence: true
  validates :happens_at, :countdown_timer, presence: true, unless: :tournament?
  validates :max_attempts, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
  }, if: :tournament?
  validates :credits_by_attempt, :join_cost_in_credits, :players, :max_attempts, presence: true, if: :tournament?
  validates :description_url, format: { with: /\Ahttps?:\/\/.+\..+\z/ }

  mount_uploader :image, ImageUploader
  mount_uploader :second_image, ImageUploader

  scope :active, -> { where(winner_id: nil, ended_at: nil).where('happens_at < ?', Time.now) }
  scope :scheduled, -> { where(winner_id: nil, ended_at: nil).where('happens_at > ?', Time.now) }
  scope :unfinished, -> { where(winner_id: nil, ended_at: nil) }
  scope :non_highlighted, -> { eager_load(:highlights).where(highlights: { target_id: nil })}
  scope :sold, -> { where.not(winner: nil, ended_at: nil).where('happens_at < ?', Time.now) }
  scope :ended, -> { where.not(ended_at: nil).where('happens_at < ?', Time.now) }
  scope :claimable_by_winner, -> (winner) { eager_load(:prize_claim).where(prize_claims: { target_id: nil }, winner: winner).where('ended_at > ?', claim_deadline)}

  just_define_datetime_picker :happens_at

  def active?
    (happens_at && happens_at.past? && winner.blank? && ended_at.blank?) || happens_at.blank?
  end

  def scheduled?
    (happens_at && happens_at.future? && winner.blank? && ended_at.blank?) || happens_at.blank?
  end

  def finished?
    ended_at.present? && happens_at && happens_at.past?
  end

  def sold?
    finished? && winner.present?
  end

  def claimable?
    sold? && ended_at > self.class.claim_deadline
  end

  def partial_value
    bids.count * increase_value
  end

  def discount_percentage
    (100 - (((final_cost/market_price) * 100))).floor
  end

  def attendees
    bids.select(:user_id).distinct.count
  end

  def check_winner
    auction_end = Time.now
    last_bid = bids.last
    if active? && happens_at && auction_end >= (happens_at + countdown_timer.seconds)
      if last_bid
        if last_bid.created_at.change(sec: last_bid.created_at.sec) + countdown_timer.seconds <= auction_end
          self.winner = last_bid.user
          self.ended_at ||= auction_end
          save
          GameNotification.publish(last_bid)
        end
      else
        self.ended_at ||= Time.now
        cancel if tournament?
        save
        GameNotification.publish(bids.new(user: User.new(username: '---')))
      end
    else
      GameNotification.publish(last_bid || bids.new(user: User.new(username: '---')))
    end
  end

  def cancel
    users.each do |user|
      AuctionMailer.canceled_game(self, user).deliver_now
    end
    bids.find_each do |bid|
      bid.refound
    end
    auction_attempts.destroy_all
    self.update_attributes(ended_at: Time.now, winner: nil)
    self.canceled = true
    GameNotification.publish(self)
  end

  def number_of_players
    if tournament?
      auction_attempts.select('DISTINCT "auction_attempts"."user_id"').count
    end
  end

  def self.search(query)
    where("title @@ :q", q: "#{query}")
  end

  def self.claim_deadline
    7.days.ago
  end

  def clear_happens_at
    self.happens_at = nil
  end
end
