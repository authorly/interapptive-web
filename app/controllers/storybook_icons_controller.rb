class StorybookIconsController < ApplicationController
  before_filter :authorize

  def create
    storybook = Storybook.find(params[:storybook_id])
    image = Image.find(params[:image_id])
    storybook.remote_icon_url = image.image.url

    if storybook.save
      respond_to do |format|
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.json { render :json => { :icon => 'Something went wrong. We could not save your icon' }, :status => :unprocessable_entity }
      end
    end
  end
end
