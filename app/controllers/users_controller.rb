class UsersController < ApplicationController
  before_filter :authorize, :only => [:edit, :update, :destroy]

  def show
    @user = User.find params[:id]

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html { render :layout => 'user_sessions' } # new.html.haml
      format.json { render :json => @user }
    end
  end

  # GET /account/settings
  def edit
    @user = current_user
  end

  # PUT /account
  # PUT /account.json
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

  # POST /users
  # POST /users.json
  def create
    @user = User.new params[:user]

    respond_to do |format|
      if @user.save
        cookies.permanent[:auth_token] = @user.auth_token
        
        format.html { redirect_to root_path, :notice => 'Welcome to Interapptive!'}
        format.json { render :json => @user, :status => :created }
      else
        format.html { render :action => :new }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /account
  # DELETE /account.json
  def destroy
    current_user.destroy

    respond_to do |format|
      format.html { redirect_to users_sign_in_path }
      format.json { head :ok }
    end
  end
end
