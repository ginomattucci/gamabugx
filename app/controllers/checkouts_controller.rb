class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: :create

  def create
    purchase = Purchase.new(permitted_params)
    if PurchasePolicy.new(current_user, purchase).create?
      authorize purchase
      redirect_to *Checkout.perform(purchase.plan, permitted_params.merge(user: current_user, purchase: purchase, ip: request.remote_ip))
    else
      redirect_to edit_user_registration_path, alert: 'Complete seu perfil primeiro!'
    end
  end

  def success
    @purchase = Purchase.find_by!(invoice: params[:checkout_id])
    authorize @purchase
  end

  private

  def permitted_params
    params.require(:purchase).permit(:months, :token, :payment_method, :plan_id,
                                     :fullname, :cpf, :address, :neighborhood,
                                     :cc_number, :cc_cvv, :cc_full_name,
                                     :cc_expiration, :konduto_user,
                                     :city, :uf, :country, :zip_code, :phone)
  end
end
