require "base64"

class ImagesController < ApplicationController
  def index
    images = current_user.storybooks.find(params[:storybook_id]).images.where(:generated => false)

    render :json => images.map(&:as_jquery_upload_response).to_json
  end

  def show
    scene = Scene.find params[:scene_id]
    raise ActiveRecord::RecordNotFound unless scene.storybook.owned_by?(current_user)
    image = scene.images.find(params[:id])

    respond_to do |format|
      format.json { render :json => image }
    end
  end

  def create
    storybook = current_user.storybooks.find(params[:storybook_id])

    respond_to do |format|
      if params[:preview]
        image = Image.create(:data_encoded_image => params[:data_url], :storybook_id => storybook.id, generated: true)
        format.json { render :json => image.as_jquery_upload_response.to_json }
      else
        images = params[:image][:files].map { |f| Image.create(:image => f, :storybook_id => storybook.id) }
        format.json { render :json => images.map(&:as_jquery_upload_response).to_json }
      end
    end
  end

  def update
    image = Image.find params[:id]
    raise ActiveRecord::RecordNotFound unless image.storybook.owned_by?(current_user)
    image.remove_image!

    data = params[:base64] ? file : params[:data_url]
    image.update_attribute(:data_encoded_image, data)

    respond_to do |format|
      format.json { render :json => image.as_jquery_upload_response }
    end
  end

  def destroy
    image = Image.find(params[:id])
    raise ActiveRecord::RecordNotFound unless image.storybook.owned_by?(current_user)
    image.try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end

  private

  def file
    params[:image][:files][0]
  end
end
