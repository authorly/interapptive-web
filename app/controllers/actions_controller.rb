class ActionsController < ApplicationController

  # GET /actions/definitions.json
  def definitions
    @definitions = ActionDefinition.includes(:attribute_definitions)

    respond_to do |format|
      format.json { render :json => @definitions.to_json(:include => :attribute_definitions) }
    end
  end

  # GET /scenes/:scene_id/actions.json
  def index
    @scene = Scene.find params[:scene_id]
    @actions = @scene.actions

    respond_to do |format|
      format.json { render :json => @actions.as_json }
    end
  end

  # GET /scenes/:scene_id/actions/:id.json
  def show
    @scene = Scene.find params[:scene_id]
    @action = @scene.actions.find params[:id]
    
    respond_to do |format|
      format.json { render :json => @action.as_json }
    end
  end

  # GET /scenes/:scene_id/keyframes/:keyframe_id/actions/new.json
  def new
    @scene = Scene.find params[:scene_id]
    @action = @scene.actions.new

    respond_to do |format|
      format.json { render :json => @action }
    end
  end

  # POST /scene/:scene_id/keyframes/:keyframe_id/actions.json
  def create
    @scene = Scene.find params.delete(:scene_id)
    @definition = ActionDefinition.find params.delete(:action_definition)[:id]
    @action = @scene.actions.create(:action_definition => @definition)
    
    @definition.attribute_definitions.each do |attr_definition|
      @action.action_attributes.create({
        :attribute_definition => attr_definition,
        :value => params['action_attributes'][attr_definition.name]['value']
      })
    end

    respond_to do |format|
      if @action.save
        format.json { render :json => @action.as_json, :status => :created }
      else
        format.json { render :json => @action.errors.to_json }
      end
    end
  end

  # PUT /scenes/:scene_id/actions/:id.json
  def update
    @action = Action.find params[:id]

    respond_to do |format|
      if @action.update_attributes params[:action]
        format.json { render :json => {:status => :ok} }
      else
        format.json { render :json => @storybook.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /scenes/:scene_id/actions/:id.json
  def destroy
    @scene = Scene.find params[:scene_id]
    @scene.actions.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { render :json => {:status => :ok} }
    end
  end
end
