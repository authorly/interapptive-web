class StorybooksController < ApplicationController
  before_filter :authorize, :except => :show

  # Backbone.js extraneous parameter hack
  param_protected [:action, :controller, :format, :storybook], :only => :update

  # GET /storybooks/:id/images.json
  def images
    @storybook = Storybook.find params[:id]
    @images = @storybook.images

    render :json => @images.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks/:id/sounds.json
  def sounds
    @storybook = Storybook.find params[:id]
    @sounds = @storybook.sounds

    render :json => @sounds.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks/:id/videos.json
  def videos
    @storybook = Storybook.find params[:id]
    @videos = @storybook.videos

    render :json => @videos.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks/:id/fonts.json
  def fonts
    @storybook = Storybook.find params[:id]
    @fonts = @storybook.fonts

    render :json => @fonts.map(&:as_jquery_upload_response).to_json
  end

  # GET /storybooks
  # GET /storybooks.json
  def index
    @storybooks = current_user.storybooks.all
    
    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => @storybooks }
    end
  end
  
  # GET /storybooks/:id
  # GET /storybooks/:id.json
  def show
    @storybook = Storybook.find params[:id]

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @storybook }
    end
  end

  # GET /storybooks/new
  # GET /storybooks/new.json
  def new
    @storybook = current_user.storybooks.new

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
    @storybook = current_user.storybooks.find params[:id]

    respond_to do |format|
      format.html # edit.html.haml
      format.json { render :json => @storybook }
    end
  end

  # PUT /storybooks/:id
  # PUT /storybooks/:id.json
  def update
    @storybook = current_user.storybooks.find params[:id]

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
    current_user.storybooks.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end
end
