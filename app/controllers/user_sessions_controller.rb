class UserSessionsController < ApplicationController
  skip_before_filter :authorize

  def new
  end 

  def create
    user = User.find_by_email params[:email]

    if user && user.authenticate(params[:password])
      cookies.permanent[:auth_token] = user.auth_token
      redirect_to root_path
    else
      flash.now.alert = "Invalid email or password."
      render "new"
    end
  end

  # TODO: This should probably be DELETE...
  # MATCH /users/sign_out
  def destroy
    cookies.delete :auth_token
    redirect_to root_path, :notice => "Signed out."
  end
end
