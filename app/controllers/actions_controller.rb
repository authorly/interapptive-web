class ActionsController < ApplicationController

  # GET /actions/definitions.json
  def definitions

    @definitions = ActionDefinition.includes(:attribute_definitions).all

    respond_to do |format|
      format.json { render :json => @definitions.to_json(:include => :attribute_definitions) }
    end
  end

  # GET /scenes/:scene_id/keyframes/:keyframe_id/actions.json
  def index
    @scene = Scene.find params[:scene_id]
    @actions = @scene.actions

    respond_to do |format|
      format.json { render :json => @actions }
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
    @keyframe = @scene.keyframes.find params.delete(:keyframe_id)
    @definition = ActionDefinition.find params.delete(:definition)[:id]
    @action = @scene.actions.create(:action_definition => @definition)
    
    @definition.attribute_definitions.each do |attr_definition|
      @action.action_attributes.create({
        :attribute_definition => attr_definition,
        :value => params[attr_definition.name],
        :keyframe => @keyframe
      })
    end

    respond_to do |format|
      if @action.save
        format.json { render :json => @action.to_json(:include => :action_attributes), :status => :created }
      else
        format.json { render :json => @action.errors.to_json }
      end
    end
  end
end
