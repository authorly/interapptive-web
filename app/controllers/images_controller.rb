class ImagesController < ApplicationController
  require "base64"

  def index
    @images = Image.all

    respond_to do |format|
      format.json { render :json => @images.collect { |p| p.as_jquery_upload_response }.to_json }
    end
  end

  def show
    @scene = Scene.find params[:scene_id]
    @image = @scene.images.find params[:id]

    respond_to do |format|
      format.json { render :json => @image }
    end
  end

  def create
    # We can use something other than the base64 param as a flag in the JSON,
    # or use a hidden field flag instead of injecting into
    # the .ajax() calls data in the JS (see keyframe index file)
    if params[:base64]
      filename = "#{(0..35).map{ rand(36).to_s(36) }.join}.png" # Random alphanumeric
      file = File.open(filename, "wb")
      file.write(Base64.decode64(params[:image][:files][0]))
      @images = params[:image][:files].map { |f| Image.create(:image => file) }
    else
      @images = params[:image][:files].map { |f| Image.create(:image => f) }
    end

    respond_to do |format|
      format.json { render :json => @images.map(&:as_jquery_upload_response).to_json }
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
end
