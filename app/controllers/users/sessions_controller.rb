class Users::SessionsController < Devise::SessionsController
  layout :set_layout

  private
  def set_layout
    if request.xhr?
      false
    else
      'application'
    end
  end
end
