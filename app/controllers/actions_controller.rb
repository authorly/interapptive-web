class ActionsController < ApplicationController
  before_filter :authorize_scene_ownership, :except => [:update, :definitions]

  def definitions
    @definitions = ActionDefinition.includes(:attribute_definitions)

    respond_to do |format|
      format.json { render :json => @definitions.to_json(:include => :attribute_definitions) }
    end
  end

  def index
    actions = @scene.actions

    respond_to do |format|
      format.json { render :json => actions.as_json }
    end
  end

  def show
    action = @scene.actions.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => action.as_json }
    end
  end

  def create
    definition = ActionDefinition.find params.delete(:action_definition)[:id]
    action = @scene.actions.create(:action_definition => definition)
    
    definition.attribute_definitions.each do |attr_definition|
      action.action_attributes.create({
        :attribute_definition => attr_definition,
        :value => params['action_attributes'][attr_definition.name]['value']
      })
    end

    respond_to do |format|
      if action.save
        format.json { render :json => action.as_json, :status => :created }
      else
        format.json { render :json => action.errors.to_json }
      end
    end
  end

  def update
    action = Action.find params[:id]

    respond_to do |format|
      if action.update_attributes params[:aktion]
        format.json { render :json => {:status => :ok} }
      else
        format.json { render :json => action.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @scene.actions.find(params[:id]).destroy

    respond_to do |format|
      format.json { render :json => {:status => :ok} }
    end
  end
end
