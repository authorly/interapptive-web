class ConfirmationsController < ApplicationController
  layout 'user_sessions'
  skip_before_filter :authorize

  def new
    @user = User.find_by_confirmation_token(params[:confirmation_token])
    if @user
      if !@user.confirmed?
        KMTS.record(@user.email, 'Visited confirmation page')
        respond_to do |format|
          format.html
        end

      else
        flash[:notice] = "You have confirmed your email. Now use your password to Sign In."
        respond_to do |format|
          format.html { redirect_to root_path }
        end
      end

    else
      flash[:notice] = "We do not have record of this email."
      respond_to do |format|
        format.html { redirect_to root_path }
      end
    end
  end

  def create
    @user = User.find_by_confirmation_token(params[:confirmation_token])

    if @user
      # Ensure users do not submit blank passwords.
      if params[:password].blank? || params[:password_confirmation].blank?
        @user.password = 'a'
        @user.password_confirmation = 'a'
      else
        @user.password = params[:password]
        @user.password_confirmation = params[:password_confirmation]
      end

      if @user.save
        @user.confirm
        flash[:notice] = "You have successfully set your password."
        KMTS.record(@user.email, 'Confirmed account')
        # Change UserSessionsController#create when a change is made
        # in cookies below.
        cookies.permanent[:auth_token] = @user.auth_token
        cookies[:email] = {
          :value    => @user.email,
          :expires  => 20.years.from_now,
          :domain   => cookie_domain
        }
        cookies.permanent[:is_admin] = @user.is_admin? if @user.is_admin?

        respond_to do |format|
          format.html { redirect_to root_path }
        end

      else
        respond_to do |format|
          format.html { render :action => :new }
        end
      end

    else
      flash[:notice] = "We do not have record of this email."
      respond_to do |format|
        format.html { redirect_to root_path }
      end
    end
  end
end
