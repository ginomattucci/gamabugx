module Payment
  class Base
    attr_accessor :user, :plan, :success, :purchase, :ip, :konduto_user

    def initialize(plan, attributes = {})
      self.plan = plan
      self.user = attributes[:user]
      attributes && attributes.each do |attr, value|
        send("#{attr}=", value) if respond_to?("#{attr}=".to_sym)
      end
    end

    def self.payment_methods
      descendants.reverse.map{|klass| [ klass.model_name, klass.payment_method ]}
    end

    def self.model_name
      I18n.t("payment.#{payment_method}")
    end

    def perform
      fail NotImplementedError
    end

    def success?
      fail NotImplementedError
    end

    def save_purchase
      fail NotImplementedError
    end

    def send_mail
      fail NotImplementedError
    end

    def payment_method
      fail NotImplementedError
    end

    def redirect_path
      fail NotImplementedError
    end

    def purchase
      @purchase ||= self.purchase || user.purchases.new
      @purchase.user ||= user
      @purchase.payment_method ||= payment_method
      @purchase.status ||= 'pending'
      @purchase.plan_name ||= plan.title
      @purchase.plan_credits ||= plan.credits
      @purchase.plan_price ||= plan.price
      @purchase.plan ||= plan
      @purchase
    end

    def finish_purchase
      save_purchase && send_mail
    end
  end
end

# require_relative 'bank_slip'
# require_relative 'credit_card'
