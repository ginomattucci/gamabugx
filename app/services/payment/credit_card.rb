module Payment
  class CreditCard < Base
    include IuguBase

    attr_accessor :token, :months

    def self.payment_method
      :credit_card
    end

    private

    def payment_method
      self.class.payment_method
    end

    def due_date
      { due_date: Date.tomorrow.in_time_zone.strftime('%d/%m/%Y') }
    end

    def charge_param
      { token: token }.tap do |params|
        params[:months] = months.to_i if months.to_i > 1
      end
    end
  end
end
