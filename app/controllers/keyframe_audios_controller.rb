class KeyframeAudiosController < ApplicationController
  before_filter :authorize
  protect_from_forgery :except => :create

  def show
    keyframe = Keyframe.find params[:keyframe_id]

    render :json => keyframe.audio_as_jquery_upload_response.to_json
  end

  def create
    keyframe = Keyframe.find params[:keyframe_id]

    keyframe.audio = params[:file]
    keyframe.save

    respond_to do |format|
      format.json { render :json => keyframe.audio_as_jquery_upload_response.to_json }
    end
  end

  def update
    keyframe = Keyframe.find(params[:keyframe_id])
    transcript = keyframe.save_and_sync_text

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
end
