class Users::RegistrationsController < Devise::RegistrationsController
  layout :set_layout

  def create
    build_resource(sign_up_params)
    # créditos iniciais do usuário
    resource.credits = 10
    resource.valid? && verify_recaptcha(model: resource, message: "Por favor, confirme que você não é um robô.", attribute: :recaptcha) && resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      redirect_path = after_update_path_for(resource)
      if params[:to].present?
        redirect_path = "#{root_url}#{params[:to]}"
      end
      respond_with resource, location: redirect_path
    else
      clean_up_passwords resource
      if request.referrer =~ %r(\A#{change_password_url})
        redirect_to change_password_path, flash: { alert: 'Verifique as informações digitadas' }
      else
        respond_with resource
      end
    end
  end

  private
  def set_layout
    if request.xhr?
      false
    else
      'application'
    end
  end
end
