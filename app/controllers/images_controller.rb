class ImagesController < ApplicationController
  # GET /images
  # GET /images.json
  def index
    @images = Image.all

    respond_to do |format|
      format.json { render :json => @images.collect { |p| p.as_jquery_upload_response }.to_json }
    end
  end

  # GET /scenes/:scene_id/images/:id
  # GET /scenes/:scene_id/image/:id.json
  def show
    @scene = Scene.find params[:scene_id]
    @image = @scene.images.find params[:id]

    respond_to do |format|
      format.json { render :json => @image }
    end
  end

  # POST /storybooks/:storybook_id/scenes
  # POST /storybooks/:storybook_id/scenes.json
  def create
    @images = params[:image][:files].map { |f| Image.create(:image => f) }

    respond_to do |format|
      format.json { render :json => @images.map(&:as_jquery_upload_response).to_json }
    end
  end

  # PUT /scenes/:scene_id/images/:id
  # PUT /scenes/:scene_id/images/:id.json
  def update
    # @scene = Scene.find params[:scene_id]
    # @image = @scene.images.find params[:id]
    #
    # respond_to do |format|
    #   if @scene.update_attributes params[:scene]
    #     format.json { render :json => @scene }
    #   else
    #     format.json { render :json => @scene.errors, :status => :unprocessable_entity }
    #   end
    # end
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
