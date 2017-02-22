class PrizeClaim < ActiveRecord::Base
  attr_accessor :skip_days

  before_update :notify_delivery

  belongs_to :user
  belongs_to :target, polymorphic: true

  validates :user, :target, :status, :full_name, :deliver_address,
            :phone_number, presence: true
  validate :claimer_is_the_winner
  validate :target_is_claimable
  validate :has_complete_information_for_status

  has_enumeration_for :status, with: PrizeClaimStatus
  just_define_datetime_picker :shipped_on

  def notify_delivery
    if status_changed? && status == PrizeClaimStatus::SHIPPED
      PrizeClaimMailer.notify_delivery(self).deliver_now
    end
  end

  def claimer_is_the_winner
    return true if user && target && user == target.winner
    errors.add(:base, :not_the_winner)
  end

  def target_is_claimable
    return true if (user && target && target.claimable?) || skip_days
    errors.add(:base, :expired)
  end

  def has_complete_information_for_status
    if status == PrizeClaimStatus::SHIPPED || status == PrizeClaimStatus::DELIVERED
      errors.add(:tracking_code, :blank) unless tracking_code.present?
      errors.add(:shipped_on, :blank) unless shipped_on.present?
    end
  end

  def shipped_on
    DateTime.new(self[:shipped_on].year, self[:shipped_on].month, self[:shipped_on].day) if self[:shipped_on]
  end
end
