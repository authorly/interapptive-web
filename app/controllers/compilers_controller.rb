class CompilersController < ApplicationController
  def create
    storybook = signed_in_as_user.storybooks.find(params[:storybook_id])
    storybook.enqueue_for_compilation(params[:platform], params[:storybook_json])

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
