class UsersController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  def new
    @user = User.new
  end


  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: "Thank you for signing up! Please Login to continue."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:name,:email, :password, :password_confirmation, :profile_picture)
  end
end
