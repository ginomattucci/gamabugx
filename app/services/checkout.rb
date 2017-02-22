class Checkout
  def self.perform(plan, attributes = {})
    if %w(bank_slip credit_card).include?(attributes[:payment_method])
      payment = Payment.const_get(attributes.delete(:payment_method).camelize).new(plan, attributes)
      payment.perform
      payment.redirect_path
    else
      [Rails.application.routes.url_helpers.plans_path, flash: { alert: 'Tente novamente' }]
    end
  end
end
