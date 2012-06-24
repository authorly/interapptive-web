class ActionsController < ApplicationController

  # GET /actions/definitions.json
  def definitions

    @definitions = ActionDefinition.includes(:attribute_definitions).all

    respond_to do |format|
      format.json { render :json => @definitions.to_json(:include => :attribute_definitions) }
    end
  end

  # GET /scenes/:scene_id/actions.json
  def index
    @scene = Scene.find params[:scene_id]
    @actions = @scene.actions

    respond_to do |format|
      format.json { render :json => @actions }
    end
  end

  # GET /scenes/:scene_id/actions/new.json
  def new
    @scene = Scene.find params[:scene_id]
    @action = @scene.actions.new

    respond_to do |format|
      format.json { render :json => @action }
    end
  end

  # POST /scene/:scene_id/actions.json
  def create
    @scene = Scene.find params[:scene_id]
    @definition = ActionDefinition.find params[:definition][:id]
    @attribute_definitions = @definition.attribute_definitions
    @action = @scene.actions.new params[:action]
    @definition 

    respond_to do |format|
      if @action.save
        format.json { render :json => @action.to_json(:include => :attributes), :status => :created }
      else
        format.json { render :json => @action.errors.to_json }
      end
    end
  end
end
