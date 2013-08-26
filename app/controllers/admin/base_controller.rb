module Admin
  class BaseController < ApplicationController
    layout 'user_sessions'

    before_filter :authorize_admin

    private

    def authorize_admin
      redirect_to sign_in_path, :alert => "You are not authorize to access that resource" unless current_user.is_admin? 
    end
  end
end
