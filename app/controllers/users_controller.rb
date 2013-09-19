class UsersController < ApplicationController
  skip_before_filter :authorize, :only => [:new, :create]

  def show
    respond_to do |format|
      format.json { render :json => current_user.backbone_response }
    end
  end

  def show_signed_in_as_user
    respond_to do |format|
      format.json { render :json => signed_in_as_user.backbone_response }
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html { render :layout => 'user_sessions' }
      format.json { render :json => @user }
    end
  end

  def edit
    @user = current_user
  end

  def update
    respond_to do |format|
      params[:user].slice!(:email, :password, :password_confirmation)

      if current_user.update_attributes params[:user]
        format.html { redirect_to current_user }
        format.json { head :ok }
      else
        format.html { render :action => :edit }
        format.json { render :json => current_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    respond_to do |format|
      format.html { render :action => 'new', :layout => 'user_sessions' }
      format.json { render :json => {}, :status => :unprocessable_entity }
    end
  end

  def destroy
    current_user.destroy

    respond_to do |format|
      format.html { redirect_to sign_in_path }
      format.json { head :ok }
    end
  end
end
