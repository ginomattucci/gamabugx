class PurchasesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :notification

  before_action :authenticate_user!, except: :konduto_notification
  after_action :verify_authorized, except: :konduto_notification
  after_action :verify_policy_scoped, only: :index

  def index
    @purchases = policy_scope(Purchase)
    authorize(@purchases)
  end

  def konduto_notification
    if params[:status] == 'APPROVED' && valid_konduto_request?
      purchase = Purchase.find(params[:order_id])
      invoice = Iugu::Invoice.fetch(purchase.invoice)
      invoice.capture
      render json: { status: 'ok' }, status: :ok
    else
      render json: { status: 'error' }, status: :forbidden
    end
  end

  private

  def valid_konduto_request?
    data = "#{params[:order_id]}##{params[:timestamp]}##{params[:status]}"
    generated = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), Rails.application.secrets.konduto_key, data)
    params[:signature] == generated
  end
end
