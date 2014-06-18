module Admin
  class SubscriptionUsersController < Admin::BaseController
    helper_method :sort_column

    def index
      is_deleted = false
      is_deleted = true if params[:deleted] == 'true'
      @users = SubscriptionUser.where(:is_deleted => is_deleted).order(sort_column + " " + sort_direction).page(params[:page]).per(50)
      @users_count = SubscriptionUser.where(:is_deleted => is_deleted).count
    end

    def search
      @users = SubscriptionUser.where('email LIKE ?', '%' + params[:q] + '%').order(sort_column + " " + sort_direction).page(params[:page]).per(50)
      render :action => :index
    end

    def destroy
      user = SubscriptionUser.find(params[:id])
      if user.update_attribute(:is_deleted, true)
        flash[:notice] = "User successfully deleted"
      else
        flash[:error] = "Something went wrong while deleting user. Please try again later."
      end

      respond_to do |format|
        format.html { redirect_to :action => :index }
      end
    end

    def restore
      user = SubscriptionUser.find(params[:id])
      if user.update_attribute(:is_deleted, false)
        flash[:notice] = "User successfully restored"
      else
        flash[:error] = "Something went wrong while restoring user. Please try again later."
      end

      respond_to do |format|
        format.html { redirect_to :action => :index }
      end
    end

    private

    def sort_column
      super(SubscriptionUser, 'id')
    end
  end
end
