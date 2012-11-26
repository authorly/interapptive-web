class CompilersController < ApplicationController
  before_filter :authorize

  def create
    storybook = Storybook.find(params[:storybook_id])
    storybook.enqueue_for_compilation(params[:storybook_json])

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
