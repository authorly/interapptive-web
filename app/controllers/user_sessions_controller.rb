class UserSessionsController < ApplicationController
  skip_before_filter :authorize

  def new
    KMTS.record(cookies[:km_id], 'Visited sign in page') if cookies[:km_id].present?
  end 

  def create
    user = User.find_by_email params[:email]

    if user && user.authenticate(params[:password])
      # Change ConfirmationsController#create when a change is made
      # in cookies below.
      cookies.permanent[:auth_token] = user.auth_token
      cookies.permanent[:km_id]      = user.kissmetrics_identifier
      if user.is_admin?
        cookies.permanent[:is_admin] = user.is_admin?
      end
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
    cookies.delete :is_admin
    cookies.delete :signed_in_as_user_id
    redirect_to root_path, :notice => "Signed out."
  end
end
