class ScenesController < ApplicationController
  before_filter :authorize
  
  # GET /storybooks/:id/scenes
  # GET /storybooks/:id/scenes.json
  def index
    @storybook = Storybook.find params[:storybook_id]
    @scenes = @storybook.scenes
    
    respond_to do |format|
      format.html
      format.json { render :json => @scenes }
    end
  end
  

  # GET /storybooks/:storybook_id/scenes/:id
  # GET /storybooks/:storybook_id/scenes/:id.json
  def show
    @storybook = Storybook.find params[:storybook_id]
    @scene = @storybook.scenes.find params[:id]

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @scene }
    end
  end

  # GET /storybooks/:storybook_id/scenes/new
  # GET /storybooks/:storybook_id/scenes/new.json
  def new
    @storybook = Storybook.find params[:storybook_id]
    @scene = @storybook.scenes.new

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @scene }
    end
  end

  # POST /storybooks/:storybook_id/scenes
  # POST /storybooks/:storybook_id/scenes.json
  def create
    @storybook = Storybook.find params[:storybook_id]
    #next_page = (@storybook.scenes.map(&:page_number).max + 1) || 1
    
    @scene = @storybook.scenes.new params[:scene]
    #@scene.page_number = next_page

    respond_to do |format|
      if @scene.save
        format.html { redirect_to show_storybook_scene_path(@storybook, @scene) }
        format.json { render :json => @scene, :status => :created }
      else
        format.html { render :new }
        format.json { render :json => @scene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /storybooks/:storybook_id/scenes/:id/edit
  # GET /storybooks/:storybook_id/scenes/:id/edit.json
  def edit
    @storybook = Storybook.find params[:storybook_id]
    @scene = @storybook.scenes.find params[:id]

    respond_to do |format|
      format.html # edit.html.haml
      format.json { render :json => @scene }
    end
  end

  # PUT /storybooks/:storybook_id/scenes/:id
  # PUT /storybooks/:storybook_id/scenes/:id.json
  def update
    @storybook = Storybook.find params[:storybook_id]
    @scene = @storybook.scenes.find params[:id]

    respond_to do |format|
      if @scene.update_attributes params[:scene]
        format.html { redirect_to show_storybook_scene_path(@storybook, @scene) }
        format.json { render :json => @scene }
      else
        format.html { render :edit }
        format.json { render :json => @scene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /storybooks/:storybook_id/scenes/:id
  # DELETE /storybooks/:storybook_id/scenes/:id.json
  def destroy
    @storybook = Storybook.find params[:storybook_id]
    @storybook.scenes.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.html { redirect_to storybook_path(@storybook) }
      format.json { head :ok }
    end
  end

  # GET /scenes/:id/images
  # GET /scenes/:id/images.json
  def images
    @scene = Scene.find params[:id]
    @images = @scene.images

    respond_to do |format|
      format.html
      format.js
      format.json { render :json => @images }
    end
  end

  # GET /scenes/:id/touch_zones
  # GET /scenes/:id/touch_zones.json
  def images
    @scene = Scene.find params[:id]
    @touch_zones = @scene.touch_zones

    respond_to do |format|
      format.html
      format.js
      format.json { render :json => @touch_zones }
    end
  end
end
