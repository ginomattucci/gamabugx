class PlansController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :notification

  before_action :authenticate_user!, except: :notification
  after_action :verify_authorized, except: :notification

  def index
    unless current_user.has_complete_profile?
      redirect_to edit_user_registration_path(to: plans_path), flash: { alert: 'Complete seu perfil primeiro' }
    end
    @plans = Plan.all
    last_purchase = current_user.purchases.last
    @purchase = Purchase.new(
      address: current_user.address || last_purchase.try(:address),
      city: current_user.city || last_purchase.try(:city),
      country: current_user.country || last_purchase.try(:country),
      cpf: current_user.cpf || last_purchase.try(:cpf),
      fullname: current_user.fullname || last_purchase.try(:fullname),
      neighborhood: current_user.neighborhood || last_purchase.try(:neighborhood),
      payment_method: :credit_card,
      phone: current_user.phone || last_purchase.try(:phone),
      plan: @plans[0],
      uf: current_user.uf || last_purchase.try(:uf),
      user: current_user,
      zip_code: current_user.zip_code || last_purchase.try(:zip_code),
    )
    authorize @purchase
  end

  def notification
    handler = Payment::NotificationHandler.new(params)
    handler.perform
    render nothing: true, status: handler.render_status
  end

  private

  def user_not_authorized
    redirect_to edit_user_registration_path, alert: 'Você precisa completar seu perfil para continuar'
  end
end
