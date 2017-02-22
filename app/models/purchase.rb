class Purchase < ActiveRecord::Base
  attr_accessor :months, :cc_number, :cc_cvv, :cc_full_name, :cc_expiration,
    :token, :konduto_user

  belongs_to :plan
  belongs_to :user

  validates :plan, :user, :plan_credits, :plan_price, :status, :payment_method,
    :invoice_url, :invoice, presence: true

  validate :user_is_complete

  def user_is_complete
    user && user.has_complete_profile?
  end
end
