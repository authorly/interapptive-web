class ScenesController < ApplicationController
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
    @scene = @storybook.scenes.find(params[:id])
    @scene.destroy if @scene.can_be_destroyed?

    respond_to do |format|
      format.json {
        if @scene.destroyed?
          render :json => {:status => :unprocessable_entity}
        else
          render :json => {:status => :ok}
        end
      }
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

  def sort
    params[:scenes].each do |scene|
      _scene = Scene.find(scene['id'])
      _scene.position = scene['position']
      _scene.save(:validate => false)
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
