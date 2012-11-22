class KeyframeTextsController < ApplicationController
  before_filter :authorize

  def index
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe_texts = @keyframe.texts

    respond_to do |format|
      format.html
      format.json { render :json => @keyframe_texts }
    end
  end

  # GET /keyframes/:keyframe_id/texts/:id
  # GET /keyframes/:keyframe_id/texts/:id.json
  def show
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe_text = @keyframe.texts.find params[:id]

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @keyframe_text }
    end
  end

  # GET /keyframes/:keyframe_id/texts/new
  # GET /keyframes/:keyframe_id/texts/new.json
  def new
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe_text = @keyframe.texts.new

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @keyframe_text }
    end
  end

  # POST /keyframes/:keyframe_id/texts
  # POST /keyframes/:keyframe_id/texts.json
  def create
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe_text = @keyframe.texts.new params[:keyframe_text]

    respond_to do |format|
      if @keyframe_text.save
        format.html { redirect_to show_keyframe_text_path(@keyframe, @keyframe_text) }
        format.json { render :json => @keyframe_text, :status => :created }
      else
        format.html { render :new }
        format.json { render :json => @keyframe_text.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /keyframes/:keyframe_id/texts/:id/edit
  # GET /keyframes/:keyframe_id/texts/:id/edit.json
  def edit
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe_text = @keyframe.texts.find params[:id]

    respond_to do |format|
      format.html # edit.html.haml
      format.json { render :json => @keyframe_text }
    end
  end

  # PUT /keyframes/:keyframe_id/texts/:id
  # PUT /keyframes/:keyframe_id/texts/:id.json
  def update
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe_text = @keyframe.texts.find params[:id]

    respond_to do |format|
      if @keyframe_text.update_attributes params[:keyframe_text]
        format.html { redirect_to show_keyframe_text_path(@keyframe, @keyframe_text) }
        format.json { render :json => @keyframe_text }
      else
        format.html { render :edit }
        format.json { render :json => @keyframe_text.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /keyframes/:keyframe_id/texts/:id
  # DELETE /keyframes/:keyframe_id/texts/:id.json
  def destroy
    @keyframe = Keyframe.find params[:keyframe_id]
    @keyframe.texts.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.html { redirect_to keyframe_path(@keyframe) }
      format.json { head :no_content }
    end
  end
end
