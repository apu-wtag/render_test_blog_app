class SessionsController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  def new
    errors = []
  end
  def create
    email = params[:session][:email]
    password = params[:session][:password]
    if email.blank? || password.blank?
      flash.now[:danger] = "Email or password can\'t be blank."
      render :new, status: :unprocessable_entity and return
    end
    user = User.find_by(email: email.downcase)
    if user&.authenticate(password)
      reset_session
      user.regenerate_session_token
      session[:session_token] = user.session_token
      session[:user_id] = user.id
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      # # --- DEBUGGING LINES START ---
      # puts "----------------------------------------"
      # puts "DEBUG: remember_me value is: '#{params[:session][:remember_me]}'"
      # puts "DEBUG: Does it equal '1'? #{params[:session][:remember_me] == '1'}"
      # puts "----------------------------------------"
      # # --- DEBUGGING LINES END ---
      redirect_to "/", notice: "Logged in!"
    else
      flash.now[:danger] = "Invalid email/password combination"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    session.delete :user_id
    redirect_to "/login", notice: "Logged out!"
  end

end
