class KeyframesController < ApplicationController
  before_filter :authorize
  
  # GET /scenes/:id/keyframes
  # GET /scenes/:id/keyframes.json
  def index
    @scene = Scene.find params[:scene_id]
    @keyframes = @scene.keyframes
    
    respond_to do |format|
      format.html
      format.json { render :json => @keyframes }
    end
  end

  # GET /scenes/:scene_id/keyframes/:id
  # GET /scenes/:scene_id/keyframes/:id.json
  def show
    @scene = Scene.find params[:scene_id]
    @keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @keyframe }
    end
  end

  # GET /scenes/:scene_id/keyframes/new
  # GET /scenes/:scene_id/keyframes/new.json
  def new
    @scene = Scene.find params[:scene_id]
    @keyframe = @scene.keyframes.new

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @keyframe }
    end
  end

  # POST /scenes/:scene_id/keyframes
  # POST /scenes/:scene_id/keyframes.json
  def create
    @scene = Scene.find params[:scene_id]
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

  # GET /scenes/:scene_id/keyframes/:id/edit
  # GET /scenes/:scene_id/keyframes/:id/edit.json
  def edit
    @scene = Scene.find params[:scene_id]
    @keyframe = @scene.keyframes.find params[:id]

    respond_to do |format|
      format.json { render :json => @keyframe }
    end
  end

  # PUT /scenes/:scene_id/keyframes/:id
  # PUT /scenes/:scene_id/keyframes/:id.json
  def update
    @scene = Scene.find params[:scene_id]
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

  # DELETE /scenes/:scene_id/keyframes/:id
  # DELETE /scenes/:scene_id/keyframes/:id.json
  def destroy
    @scene = Scene.find params[:scene_id]
    @scene.keyframes.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { render :json => {:status => :ok} }
    end
  end
end
