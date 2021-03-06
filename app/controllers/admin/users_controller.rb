module Admin
  class UsersController < Admin::BaseController
    def index
      is_deleted = false
      is_deleted = true if params[:deleted] == 'true'
      @users = User.where(:is_deleted => is_deleted).order('id DESC').page(params[:page]).per(50)
    end

    def search
      @users = User.where('email LIKE ?', '%' + params[:q] + '%').order('id DESC').page(params[:page]).per(50)
      render :action => :index
    end

    def edit
      @user = User.find(params[:id])
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      params[:user].slice!(:name, :city, :company, :email, :is_admin, :allowed_storybooks_count)

      @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { redirect_to :action => :edit }
      end
    end

    def new
      @user = User.new
    end

    def create
      params[:user].slice!(:name, :city, :company, :email, :is_admin, :allowed_storybooks_count)
      @user = User.new(params[:user])

      if @user.reset_password
        respond_to do |format|
          format.html { redirect_to edit_admin_user_url(@user.id) }
        end
      else
        respond_to do |format|
          format.html { render :action => :new }
        end
      end
    end

    def destroy
      user = User.find(params[:id])
      if user.update_attribute(:is_deleted, true)
        flash[:notice] = "User successfully deleted"
      else
        flash[:error] = "Something went wrong while deleting user. Please try again later."
      end

      respond_to do |format|
        format.html { redirect_to :action => :index }
      end
    end

    def send_invitation
      @user = User.find(params[:id])
      if @user.reset_password
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js
        end
      end
    end

    def restore
      user = User.find(params[:id])
      if user.update_attribute(:is_deleted, false)
        flash[:notice] = "User successfully restored"
      else
        flash[:error] = "Something went wrong while restoring user. Please try again later."
      end

      respond_to do |format|
        format.html { redirect_to :action => :index }
      end
    end
  end
end
