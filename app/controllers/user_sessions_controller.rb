class UserSessionsController < ApplicationController
  # GET /account/sign_in
  def new
  end

  # POST /account/sign_in
  def create
    user = User.find_by_email params[:email]

    if user && user.authenticate(params[:password])
      sign_in(user)
      redirect_to root_path
    else
      flash.now.alert = "Invalid email or password."
      render "new"
    end
  end

  # POST /account/sign_out
  def destroy
    cookies.delete :auth_token
    redirect_to root_path, :notice => "Signed out."
  end
end
