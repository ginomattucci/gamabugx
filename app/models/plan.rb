class Plan < ActiveRecord::Base
  has_many :purchases

  validates :credits, :price, presence: true
  validates :credits, numericality: { only_integer: true }
  validates :credits, :price, numericality: { greater_than_or_equal_to: 1 }
end
