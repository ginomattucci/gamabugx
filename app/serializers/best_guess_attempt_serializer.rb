class BestGuessAttemptSerializer < ActiveModel::Serializer
  attributes :value_in_credits, :type, :joined

  belongs_to :best_guess
  belongs_to :user

  def type
    object.class.name
  end
end
