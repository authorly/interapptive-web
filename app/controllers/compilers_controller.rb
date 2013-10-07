class CompilersController < ApplicationController
  def create
    storybook = signed_in_as_user.storybooks.find(params[:storybook_id])
    # Application download email should go the user who is compiling the application
    # and not to the person whom the application belongs.
    storybook.enqueue_for_compilation(params[:platform], params[:storybook_json], current_user)

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
