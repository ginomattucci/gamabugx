class Highlight < ActiveRecord::Base
  belongs_to :target, polymorphic: true

  validates :target, presence: true
  validates :target_id, uniqueness: { scope: [ :target_type, :target_id ] }
end
