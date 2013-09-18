module Admin
  class StorybookAssignmentsController < Admin::BaseController
    def edit
      @user = User.find(params[:id])
      respond_to do |format|
        format.html
      end
    end

    def update
      @user = User.find(params[:id])
      @storybook = Storybook.find(params[:storybook_id])

      if @storybook.update_attribute(:user_id, @user.id)
        flash[:notice] = "Storybook successfully assigned to User."
        respond_to do |format|
          format.html { redirect_to admin_users_url }
        end
      else
        flash[:error] = "There was some error assigning Storybook to User. Please try again"
        respond_to do |format|
          format.html { render :action => :edit }
        end
      end
    end
  end
end
