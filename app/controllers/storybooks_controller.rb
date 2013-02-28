class StorybooksController < ApplicationController
  skip_before_filter :authorize, :only => :show
  before_filter :find_storybook, :except => [:create, :index]

  # Backbone.js extraneous parameter hack
  param_protected [:action, :controller, :format, :storybook], :only => :update

  # GET /storybooks/:id/images.json
  def images
    @images = @storybook.images

    render :json => @images.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks/:id/sounds.json
  def sounds
    @sounds = @storybook.sounds

    render :json => @sounds.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks/:id/videos.json
  def videos
    @videos = @storybook.videos

    render :json => @videos.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks/:id/fonts.json
  def fonts
    @fonts = @storybook.fonts

    render :json => @fonts.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks.json
  def index
    @storybooks = current_user.storybooks.all
    respond_to do |format|
      format.json { render :json => @storybooks }
    end
  end
  
  # GET /storybooks/:id
  # GET /storybooks/:id.json
  def show
    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @storybook }
    end
  end

  # GET /storybooks/new
  # GET /storybooks/new.json
  def new
    respond_to do |format|
      format.html # new.html.haml
      format.json { render :json => @storybook }
    end
  end

  # POST /storybooks
  # POST /storybooks.json
  def create
    @storybook = current_user.storybooks.new params[:storybook]

    respond_to do |format|
      if @storybook.save
        format.html { redirect_to storybook_path(@storybook) }
        format.json { render :json => @storybook, :status => :created }
      else
        format.html { render :new }
        format.json { render :json => @storybook.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /storybooks/:id/edit
  # GET /storybooks/:id/edit.json
  def edit
    respond_to do |format|
      format.html # edit.html.haml
      format.json { render :json => @storybook }
    end
  end

  # PUT /storybooks/:id
  # PUT /storybooks/:id.json
  def update

    # Remove Backbone hack parameter from attributes
    # params[:_method] = params.delete(:_method) if params.has_key? :_method

    respond_to do |format|
      if @storybook.update_attributes params
        format.html { redirect_to storybook_path(@storybook) }
        format.json { render :json => @storybook }
      else
        format.html { render :edit }
        format.json { render :json => @storybook.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /storybooks/:id
  # DELETE /storybooks/:id.json
  def destroy
    @storybook.try(:destroy)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  private

  def find_storybook
    @storybook = current_user.storybooks.find params[:id]
  end
end
