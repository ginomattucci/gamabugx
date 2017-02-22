module Payment
  class BankSlip < Base
    include IuguBase

    def self.payment_method
      :bank_slip
    end

    private

    def payment_method
      self.class.payment_method
    end

    def due_date
      { due_date: Date.today.in_time_zone.strftime('%d/%m/%Y') }
    end

    def charge_param
      { method: 'bank_slip' }
    end
  end
end
