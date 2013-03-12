class PasswordResetsController < ApplicationController
  layout 'user_sessions'
  skip_before_filter :authorize

  def new
  end

  def create
    user = User.find_by_email params[:email]
    user.send_password_reset if user
    redirect_to sign_in_url, :notice => "Email sent with password reset instructions."
  end
  
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end
  
  def update
    @user = User.find_by_password_reset_token!(params[:id])

    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_url, :alert => "Password reset has expired."
    elsif params[:user][:password].blank? || params[:user][:password_confirmation].blank?
      redirect_to edit_password_reset_url(@user.password_reset_token), :alert => "Can not accept blank password"
    elsif @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      redirect_to root_url, :notice => "Password has been reset!"
    else
      render :edit
    end
  end
end
