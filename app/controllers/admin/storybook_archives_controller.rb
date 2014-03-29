module Admin
  class StorybookArchivesController < Admin::BaseController
    def create
      storybook = Storybook.find(params[:storybook_id])
      storybook.enqueue_for_resource_archiving(params[:storybook_json], current_user)
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end
end
