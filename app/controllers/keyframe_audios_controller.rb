class KeyframeAudiosController < ApplicationController
  protect_from_forgery :except => :create
  before_filter :find_keyframe

  def show
    render :json => @keyframe.audio_as_jquery_upload_response.to_json
  end

  def create
    @keyframe.audio = params[:file]
    @keyframe.save

    respond_to do |format|
      format.json { render :json => @keyframe.audio_as_jquery_upload_response.to_json }
    end
  end

  def update
    transcript = @keyframe.save_and_sync_text

    if transcript.blank?
      respond_to do |format|
        format.json { render :json => { :audio => "Unprocessable file" }.to_json, :status => :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.json { render :json => transcript.to_json }
      end
    end
  end

  private

  def find_keyframe
    @keyframe = Keyframe.find(params[:keyframe_id])
    raise ActiveRecord::RecordNotFound unless @keyframe.scene.storybook.owned_by?(current_user)
  end
end
