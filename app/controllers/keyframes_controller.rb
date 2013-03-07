class KeyframesController < ApplicationController
  before_filter :authorize_scene_ownership

  def index
    keyframes = @scene.keyframes

    respond_to do |format|
      format.json { render :json => keyframes }
    end
  end

  def show
    keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      format.json { render :json => keyframe }
    end
  end

  def create
    @keyframe = @scene.keyframes.new params[:keyframe]

    respond_to do |format|
      if @keyframe.save
        format.json { render :json => @keyframe, :status => :created }
      else
        format.json { render :json => @keyframe.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      if @keyframe.update_attributes params[:keyframe]
        format.json { render :json => @keyframe }
      else
        format.json { render :json => @keyframe.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @scene.keyframes.find(params[:id]).destroy

    respond_to do |format|
      format.json { render :json => {:status => :ok} }
    end
  end

  def sort
    params[:keyframes].each_with_index do |keyframe, index|
      _keyframe = Keyframe.find(keyframe['id'])
      _keyframe.position = keyframe['position']
      _keyframe.save(:validate => false)
    end

    render :json => {:status => :ok}
  end
end
