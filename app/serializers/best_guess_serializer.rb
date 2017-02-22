class BestGuessSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :type, :id, :finished, :value, :sold, :discount_percentage,
    :players, :number_of_players, :tournament, :existing_attempts, :title, :url

  belongs_to :winner, serializer: UserSerializer

  def type
    object.class.name
  end

  def finished
    object.finished?
  end

  def value
    object.partial_value
  end

  def sold
    object.sold?
  end

  def discount_percentage
    object.discount_percentage
  end

  def number_of_players
    if object.tournament?
      object.best_guess_attempts.count
    end
  end

  def existing_attempts
    if object.tournament?
      object.best_guess_attempts.joins(:user).group('"users"."username"').count
    end
  end

  def url
    best_guess_path(object)
  end
end
