module Admin
  class UsersController < Admin::BaseController
    def index
      @users = User.order('id').page(params[:page]).per(3)
    end
  end
end
