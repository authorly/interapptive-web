class ImagesController < ApplicationController
  require "base64"

  def index
    @images = Image.all

    respond_to do |format|
      format.json { render :json => @images.map(&:as_jquery_upload_response).to_json }
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

    filename = "#{(0..35).map{ rand(36).to_s(36) }.join}.png" # Random alphanumeric
    file = File.open(filename, "wb")
    file.write(Base64.decode64(params[:image][:files][0]))
    debugger
    # @place = Place.find(params[:id])
    # params[:place][:images_attributes].each_key { |key|
    #   if params[:place][:images_attributes][key.to_sym][:remove_image] == "1"
    #     @image = Image.find(params[:place][:images_attributes][key.to_sym][:id])
    #     @image.remove_image!
    #     @image.destroy
    #     params[:place][:images_attributes].delete(key.to_sym)
    #   end
    # }

    #@place.update_attributes(params[:place])

    respond_to do |format|
      if @image.update_attribute(:file, params[:image][:files][0])
        format.json { head :ok }
      else
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
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
