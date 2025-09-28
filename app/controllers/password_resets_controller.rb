class PasswordResetsController < ApplicationController
  before_action :get_user, only: [ :edit, :update ]
  before_action :valid_user, only: [ :edit, :update ]
  before_action :check_expiration, only: [ :edit, :update ]
  before_action :log_out_if_different_user, only: [ :edit, :update ]
  # before_action :log_in_if_expired, only: [:edit, :update]
  def new
  end
  def create
    email = params[:password_reset][:email].to_s.strip.downcase
    user  = User.find_by(email: email)
    if user
      if user.kept?
        user.create_reset_digest
        ResetMailerJob.perform_async(user.id, user.reset_token)
        redirect_to login_path, notice: "We have sent a password reset link, Please check your email."
      else
        redirect_to sign_up_path, alert: "This account has been banned. Please use another email or username to sign up."
      end
    else
      redirect_to login_path, notice: "If an account with that email exists, we have sent a password reset link."
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be blank")
      render :edit, status: :unprocessable_entity and return
    elsif @user.update(user_params)
      log_out if current_user
      @user.update_columns(reset_digest: nil, reset_sent_at: nil)
      redirect_to login_path, notice: "Password successfully updated.Please login again."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  private
  def get_user
    email = params[:email] || params.dig(:user, :email)
    if email
      @user = User.kept.find_by(email: email.downcase)
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
