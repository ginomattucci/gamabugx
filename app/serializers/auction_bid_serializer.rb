class AuctionBidSerializer < ActiveModel::Serializer
  attributes :type, :value_in_credits, :happens_at, :credits_remaining, :blink

  belongs_to :auction
  belongs_to :user


  def type
    object.class.name
  end

  def happens_at
    object.created_at.to_i * 1000
  end

  def credits_remaining
    object.auction_attempt.credits if object.auction_attempt
  end
end
