module Admin
  class SubscriptionUsersController < Admin::BaseController
    def index
      @users = SubscriptionUser.order('id DESC').page(params[:page]).per(50)
    end

    def search
      @users = SubscriptionUser.where('email LIKE ?', '%' + params[:q] + '%').order('id DESC').page(params[:page]).per(50)
      render :action => :index
    end
  end
end
