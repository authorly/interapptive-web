class ImagesController < ApplicationController
  require "base64"

  def index
    @images = Image.all
    render :json => @images.map(&:as_jquery_upload_response).to_json
  end

  def show
    @scene = Scene.find params[:scene_id]
    @image = @scene.images.find params[:id]

    respond_to do |format|
      format.json { render :json => @image }
    end
  end

  def create
    if params[:base64]
      filename = "#{(0..35).map{ rand(36).to_s(36) }.join}.png" # Random alphanumeric
      file = File.open(filename, "wb")
      file.write(Base64.decode64(params[:image][:files][0]))
      @images = [Image.create(:image => file)]
    else
      @images = params[:image][:files].map { |f| Image.create(:image => f) }
    end

    respond_to do |format|
      format.json { render :json => @images.map(&:as_jquery_upload_response).to_json }
    end
  end

  # POST /images/:id
  # PUT /images/:id.format
  def update
    @image = Image.find params[:id]
    @image.remove_image!

    filename = "#{(0..35).map{ rand(36).to_s(36) }.join}.png" # Random alphanumeric
    file = File.open(filename, "wb")
    file.write(Base64.decode64(params[:image][:files][0]))

    @image.update_attribute(:image, file)

    respond_to do |format|
      format.json { render :json => [@image.as_jquery_upload_response.to_json] }
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
