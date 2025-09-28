class UserMailer < ApplicationMailer
  def password_reset(user, token)
    @user = user
    @token = token
    # puts "pppp #{token} pppp"
    mail to: @user.email, subject: "Password Reset"
  end
end
