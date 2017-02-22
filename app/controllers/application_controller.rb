class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :username, :phone, :password, :password_confirmation, :birthday,
               :terms_of_service)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :username, :password, :password_confirmation, :birthday,
               :current_password, :address, :document_id, :cpf, :city, :country,
               :fullname, :neighborhood, :phone, :uf, :zip_code)
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "Você não tem permissão para fazer isso."
    redirect_to(request.referrer || root_path)
  end
end
