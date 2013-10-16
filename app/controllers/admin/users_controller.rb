module Admin
  class UsersController < Admin::BaseController
    def index
      @users = User.order('id').page(params[:page]).per(50)
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
  end
end
