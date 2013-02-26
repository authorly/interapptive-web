require "base64"

class ImagesController < ApplicationController
  def index
    images = Image.where(:storybook_id => params[:storybook_id], :generated => false)

    render :json => images.map(&:as_jquery_upload_response).to_json
  end

  def show
    @scene = Scene.find params[:scene_id]
    @image = @scene.images.find params[:id]

    respond_to do |format|
      format.json { render :json => @image }
    end
  end

  def create
    storybook = Storybook.find params[:storybook_id]

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

  # POST /images/:id
  # PUT /images/:id.format
  def update
    @image = Image.find params[:id]
    @image.remove_image!

    data = params[:base64] ? file : params[:data_url]
    @image.update_attribute(:data_encoded_image, data)

    respond_to do |format|
      format.json { render :json => [@image.as_jquery_upload_response] }
    end
  end

  # DELETE /images/:id
  # DELETE /images/:id.json
  def destroy
    Image.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end

  private

  def file
    params[:image][:files][0]
  end
end
