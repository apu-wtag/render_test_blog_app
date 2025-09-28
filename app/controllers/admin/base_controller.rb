class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_admin
  private
  def require_admin
    unless current_user&.admin?
      user_not_authorized
    end
  end
end
