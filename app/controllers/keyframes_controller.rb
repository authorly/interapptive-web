class KeyframesController < ApplicationController
  before_filter :find_scene, :except => :sort

  def index
    @keyframes = @scene.keyframes

    respond_to do |format|
      format.html
      format.json { render :json => @keyframes }
    end
  end

  def show
    @keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @keyframe }
    end
  end

  def new
    @keyframe = @scene.keyframes.new

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @keyframe }
    end
  end

  def create
    @keyframe = @scene.keyframes.new params[:keyframe]

    respond_to do |format|
      if @keyframe.save
        format.html { redirect_to show_scene_keyframe_path(@scene, @keyframe) }
        format.json { render :json => @keyframe, :status => :created }
      else
        format.html { render :new }
        format.json { render :json => @keyframe.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      format.json { render :json => @keyframe }
    end
  end

  def update
    @keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      if @keyframe.update_attributes params[:keyframe]
        format.html { redirect_to show_scene_keyframe_path(@scene, @keyframe) }
        format.json { render :json => @keyframe }
      else
        format.html { render :edit }
        format.json { render :json => @keyframe.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @scene.keyframes.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { render :json => {:status => :ok} }
    end
  end

  def sort
    params[:keyframes].each_with_index do |keyframe, index|
      _keyframe = Keyframe.find(keyframe['id'])
      _keyframe.position = keyframe['position']
      _keyframe.save!
    end

    render :json => {:status => :ok}
  end

  private

  def find_scene
    @scene = Scene.find(params[:scen_id])
    raise ActiveRecord::RecordNotFound unless @scene.storybook.owned_by?(current_user)
  end

end
