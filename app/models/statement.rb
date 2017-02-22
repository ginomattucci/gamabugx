class Statement < ActiveRecord::Base
  belongs_to :best_guess
  has_many :statement_answers
  validates :content, presence: true, unless: :image?

  mount_uploader :image, ImageUploader
end
