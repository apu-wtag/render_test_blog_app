class UsersController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  def new
    @user = User.new
  end
  def show
  end
  def edit
  end
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: "Thank you for signing up! Please Login to continue."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Your account has been updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def check_username
    username = params[:user_name].to_s.strip.downcase
    available = username.present? && !User.where("LOWER(user_name) = ?", username).exists?
    render json: { available: available }
  end


  private
  def user_params
    params.require(:user).permit(:user_name, :name,:email, :password, :password_confirmation,:bio, :profile_picture)
  end
  def set_user
    @user = User.find(params[:id])
  end
end
