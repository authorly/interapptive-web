class SoundsController < ApplicationController
  def index
    @sounds = Sound.all

    render :json => @sounds.collect { |p| p.as_jquery_upload_response }.to_json
  end

  def create
    
    @scene = Scene.find params[:scene_id]

    @sounds = params[:sound][:files].map { |f| Sound.create(:sound => f) }
    
    respond_to do |format|
      format.json { render :json => @sounds.map(&:as_jquery_upload_response).to_json }
    end
  end

  # DELETE /fonts/:id.json
  def destroy
    Sound.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
