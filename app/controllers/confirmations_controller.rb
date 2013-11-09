class ConfirmationsController < ApplicationController
  layout 'user_sessions'
  skip_before_filter :authorize

  def new
    @user = User.find_by_confirmation_token(params[:confirmation_token])
    if @user
      if !@user.confirmed?
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
        # Change UserSessionsController#create when a change is made
        # in cookies below.
        cookies.permanent[:auth_token] = @user.auth_token
        if @user.is_admin?
          cookies.permanent[:is_admin] = @user.is_admin?
        end
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
