module IuguBase
  extend ActiveSupport::Concern

  included do
    attr_reader :charge
  end

  def perform
    if charge! && success?
      finish_purchase
      konduto = KondutoRequest.new(ip: ip, konduto_user: konduto_user, purchase: purchase, user: user)
      analyze = konduto.analyze
      if analyze.recommendation == 'APPROVE'
        invoice.capture
      end
    else
      invoice.cancel
    end
    success?
  end

  def redirect_path
    if success?
      [Rails.application.routes.url_helpers.checkout_success_path(purchase.invoice), flash: { notice: "Compra realizada com sucesso!" }]
    else
      [Rails.application.routes.url_helpers.plans_path, flash: { charge_messages: charge.try(:message) || 'Verifique os dados digitados' } ]
    end
  end

  private

  def items
    [
      {
        description: "#{plan.model_name.human} #{plan.title}",
        quantity: 1,
        price_cents: (plan.price * 100).to_i
      }
    ]
  end

  def charge!
    @charge ||= Iugu::Charge.create(charge_param.merge({
      invoice_id: invoice.id,
      payer: payer
    }))
  end

  def payer
    {
      email: user.email,
      cpf_cnpj: user.cpf,
      name: user.fullname,
      address: {
        street: purchase.address,
        city: purchase.city,
        state: purchase.uf,
        country: purchase.country,
        zip_code: purchase.zip_code,
      }
    }
  end

  def invoice
    @invoice ||= Iugu::Invoice.create(due_date.merge({
      email: user.email,
      payer: payer,
      items: items
    }))
  end

  def success?
    charge && charge.success
  end

  def save_purchase
    purchase.attributes = {
      invoice: invoice.id,
      invoice_url: invoice.secure_url,
    }
    purchase.save
  end

  def send_mail
    # TODO PurchaseMailer.pending_payment(purchase).deliver_now
    true
  end
end
