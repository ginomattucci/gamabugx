class AuctionSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :type, :id, :finished, :value, :attendees, :happens_at, :sold,
    :canceled, :discount_percentage, :tournament, :number_of_players, :players,
    :existing_attempts, :joined, :max_attempts, :rebuy, :title, :url

  def canceled
    object.canceled || false
  end

  def type
    object.class.name
  end

  def finished
    object.finished?
  end

  def sold
    object.sold?
  end

  def value
    object.partial_value
  end

  def happens_at
    object.happens_at.to_i * 1000
  end

  def discount_percentage
    object.discount_percentage
  end

  def existing_attempts
    if object.tournament?
      object.auction_attempts.joins(:user).group('"users"."username"').count
    end
  end

  def url
    auction_path(object)
  end
end
