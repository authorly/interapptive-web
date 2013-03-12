class StorybookIconsController < ApplicationController
  def create
    storybook = current_user.storybooks.find(params[:storybook_id])
    image = storybook.images.find(params[:image_id])
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
