class Banner < ActiveRecord::Base
  validates :title, :url, :image, presence: :true
  validates :url, format: { with: /\Ahttps?:\/\/.+\..+\z/ }

  mount_uploader :image, ImageUploader
end
