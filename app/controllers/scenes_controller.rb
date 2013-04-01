class ScenesController < ApplicationController
  before_filter :authorize_storybook_ownership, :except => [:images, :sort]

  def index
    scenes = @storybook.scenes

    respond_to do |format|
      format.json { render :json => scenes }
    end
  end


  def show
    scene = @storybook.scenes.find params[:id]

    respond_to do |format|
      format.json { render :json => scene }
    end
  end

  def create
    scene = @storybook.scenes.new params[:scene]

    respond_to do |format|
      if scene.save
        format.json { render :json => scene, :status => :created }
      else
        format.json { render :json => scene.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    scene = @storybook.scenes.find params[:id]

    respond_to do |format|
      if scene.update_attributes params[:scene]
        format.json { render :json => scene }
      else
        format.json { render :json => scene.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    scene = @storybook.scenes.find(params[:id])
    scene.destroy if scene.can_be_destroyed?

    respond_to do |format|
      format.json {
        if scene.destroyed?
          render :json => {:status => :ok}
        else
          render :json => {:status => :unprocessable_entity}
        end
      }
    end
  end

  def images
    scene = Scene.find params[:id]
    raise ActiveRecord::RecordNotFound unless scene.storybook.owned_by?(current_user)
    images = scene.images

    respond_to do |format|
      format.json { render :json => images }
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
