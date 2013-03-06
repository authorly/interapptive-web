class SoundsController < ApplicationController
  before_filter :find_storybook, :except => :destroy

  def index
    sounds = @storybook.sounds

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
    raise ActiveRecord::RecordNotFound unless sound.storybook.owned_by?(current_user)
    sound.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end

  private

  def find_storybook
    @storybook = current_user.storybooks.find(params[:storybook_id])
  end
end
