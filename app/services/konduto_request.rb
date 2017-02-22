
class KondutoRequest
  attr_reader :api, :ip, :konduto_user, :purchase, :plan, :user

  def initialize(ip:, konduto_user:, purchase:, user:)
    @api = KondutoRuby.new(Rails.application.secrets.konduto_key)
    @ip = ip
    @konduto_user = konduto_user
    @plan = purchase.plan
    @purchase = purchase
    @user = user
  end

  def analyze
    api.analyze(order)
  end

  private

  def order
    KondutoRuby::KondutoOrder.new({
      analyze: purchase.payment_method == 'credit_card',
      billing: billing,
      currency: 'BRL',
      customer: customer,
      id: purchase.id.to_s,
      installments: [purchase.months.to_i, 1].max,
      ip: ip,
      payment: payment,
      purchased_at: purchase.created_at.iso8601,
      shopping_cart: shopping_cart,
      total_amount: purchase.plan_price.to_f + 0.8,
      visitor: konduto_user,
    })
  end

  def billing
    {
      name: purchase.fullname,
      address1: purchase.address,
      address2: purchase.neighborhood,
      city: purchase.city,
      state: purchase.uf,
      zip: purchase.zip_code,
      country: purchase.country,
    }
  end

  def customer
    {
      id: user.id.to_s,
      name: user.fullname,
      email: user.email,
      dob: user.birthday.iso8601,
      tax_id: purchase.cpf,
      phone1: purchase.phone,
      created_at: user.created_at.to_date.iso8601,
      new: user.purchases.count.zero?,
      vip: user.purchases.count > 20
    }
  end

  def payment
    if purchase.payment_method == 'credit_card'
      [
        {
          bin: purchase.cc_number.gsub(' ', '')[0...6],
          expiration_date: "#{purchase.cc_expiration[0...2]}#{Date.today.year.to_s[0..-3]}#{purchase.cc_expiration[3..4]}",
          last4: purchase.cc_number.gsub(' ', '')[-4..-1],
          status: 'pending',
          type: 'credit',
        }
      ]
    else
      [
        {
          type: 'boleto',
        }
      ]
    end
  end

  def shopping_cart
    [
      {
        category: 1802,
        name: plan.title,
        unit_cost: plan.price.to_f,
        quantity: 1,
        created_at: plan.created_at.to_date.iso8601
      }
    ]
  end
end
