class VideosController < ApplicationController
  def index
    @videos = Video.all

    render :json => @videos.collect { |p| p.as_jquery_upload_response }.to_json
  end

  def create
    @videos = params[:video][:files].map { |f| Video.create(:video => f) }

    respond_to do |format|
      format.json { render :json => @videos.map(&:as_jquery_upload_response).to_json }
    end
  end

  # DELETE /videos/:id.json
  def destroy
    Video.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end