class ScenesController < ApplicationController
  before_filter :authorize

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
    @scene = @storybook.scenes.new params[:scene]

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
      if @scene.save
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
end
