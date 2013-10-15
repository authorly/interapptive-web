class SoundsController < ApplicationController
  before_filter :authorize_storybook_ownership, :except => :destroy

  def index
    sounds = @storybook.sounds
    sounds = sounds.where(:id => params[:sound_ids]) if params[:sound_ids].present?

    render :json => sounds.map(&:as_jquery_upload_response).to_json
  end

  def create
    sounds = params[:sound][:files].map { |f| Sound.create(:sound => f, :storybook_id => @storybook.id) }
    
    respond_to do |format|
      format.json { render :json => sounds.map(&:as_jquery_upload_response).to_json }
    end
  end

  def destroy
    sound = Sound.find(params[:id])
    raise ActiveRecord::RecordNotFound unless sound.storybook.owned_by?(signed_in_as_user)
    sound.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
