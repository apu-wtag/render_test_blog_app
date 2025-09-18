class SessionsController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  def new
    errors = []
  end
  def create
    email_or_username = params[:session][:login]
    password = params[:session][:password]
    if email_or_username.blank? || password.blank?
      flash.now[:danger] = "Email or password can\'t be blank."
      render :new, status: :unprocessable_entity and return
    end
    email_or_username.downcase!
    # user = User.find_by(email: email_or_username) || User.find_by(user_name: email_or_username)
    user = User.where("email = ? OR user_name = ?", email_or_username, email_or_username).first
    if user&.authenticate(password)
      if user.kept?
        log_in(user)
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_to "/", notice: "Logged in!"
      else
        flash.now[:danger] = "This account is banned"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:danger] = "Invalid email/username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to "/login", notice: "Logged out!"
  end

end
