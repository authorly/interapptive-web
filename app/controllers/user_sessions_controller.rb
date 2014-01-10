class UserSessionsController < ApplicationController
  skip_before_filter :authorize

  def new
    if cookies[:email].present?
      KMTS.record(cookies[:email], 'Visited sign in page')
    elsif cookies[:kmts_id].present?
      KMTS.record(cookies[:kmts_id], 'Visited sign in page')
    end
  end 

  def create
    user = User.find_by_email params[:email]

    if user && user.authenticate(params[:password])
      KMTS.alias(user.email, user.kissmetrics_identifier)
      # Change ConfirmationsController#create when a change is made
      # in cookies below.
      cookies.permanent[:auth_token] = user.auth_token
      # We save email of the user in cookies so that later on we
      # can use it to record kissmetric event on
      # UserSessionsController#new.

      cookies[:email] = {
        :value    => user.email,
        :expires  => 20.years.from_now,
        :domain   => cookie_domain
      }
      cookies.permanent[:is_admin] = user.is_admin? if user.is_admin?

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
    cookies.delete :km_aliased
    redirect_to root_path, :notice => "Signed out."
  end
end
