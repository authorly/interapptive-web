class ImagesController < ApplicationController
  def index
    # TODO: Associate image with current_user and scene
    @images = Image.all

    render :json => @images.collect { |p| p.as_jquery_upload_response }.to_json
  end

  def create
    @images = params[:image][:files].map { |f| Image.create(:image => f) }

    respond_to do |format|
      format.json { render :json => @images.map(&:as_jquery_upload_response).to_json }
    end
  end

  # DELETE /images/:id.json
  def destroy
    Image.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
