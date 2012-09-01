class FontsController < ApplicationController
  def index
    @fonts = Font.all

    render :json => @fonts.collect { |p| p.as_jquery_upload_response }.to_json
  end

  def create
    
    @scene = Scene.find params[:scene_id]

    if params[:base64]
      file = write_file
      @fonts = [Font.create(:font => file)]
    else
      @fonts = params[:font][:files].map { |f| Font.create(:font => f) }
      @fonts.each do |i|
        @scene.fonts << i
      end
    end
    
    respond_to do |format|
      format.json { render :json => @fonts.map(&:as_jquery_upload_response).to_json }
    end
  end

  # DELETE /fonts/:id.json
  def destroy
    Font.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
