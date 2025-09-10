class PasswordResetsController < ApplicationController
  before_action :get_user , only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :log_out_if_different_user, only: [:edit, :update]
  # before_action :log_in_if_expired, only: [:edit, :update]
  def new
  end
  def create
    @user = User.find_by(email: params[:password_reset][:email])
    if @user
      @user.create_reset_digest
      # puts "xxxx #{@user.reset_token} xxxx"
      ResetMailerJob.perform_async(@user.id, @user.reset_token)
    end
    redirect_to login_path, notice: "If an account with that email exists, we have sent a password reset link."
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be blank")
      render :edit, status: :unprocessable_entity and return
    elsif @user.update(user_params)
      @user.regenerate_session_token
      @user.forget
      reset_session
      @user.update!(reset_digest: nil, reset_sent_at: nil)
      # puts  "Testing for debug"
      redirect_to login_path, notice: "Password successfully updated.Please login again."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  private
  def get_user
    email = params[:email] || params.dig(:user, :email)
    if email
      @user = User.find_by(email: email.downcase)
    end

  end
  def valid_user
    unless @user&.authenticated?(:reset, params[:id])
      redirect_to login_path, notice: "Invalid password reset link"
    end
  end
  def check_expiration
    if @user.password_reset_expired?
      redirect_to new_password_reset_url, notice: "Password reset has expired"
    end
  end

  def log_out_if_different_user
    if current_user && current_user.email.downcase != (params[:email] || params.dig(:user, :email))
      log_out
      flash[:notice] = "You have been logged out to proceed with the password reset for the correct account"
    end
  end
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
