class SoundsController < ApplicationController
  before_filter :authorize

  def index
    sounds = Sound.where(:storybook_id => params[:storybook_id])

    render :json => sounds.map(&:as_jquery_upload_response).to_json
  end

  def create
    
    storybook = Storybook.find params[:storybook_id]

    sounds = params[:sound][:files].map { |f| Sound.create(:sound => f, :storybook_id => storybook.id) }
    
    respond_to do |format|
      format.json { render :json => sounds.map(&:as_jquery_upload_response).to_json }
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
