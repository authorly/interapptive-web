class ActionsController < ApplicationController
  def definitions
    @definitions = ActionDefinition.includes(:attribute_definitions).all

    respond_to do |format|
      format.json { render :json => @definitions.to_json(:include => :attribute_definitions) }
    end
  end

  def index
    @actions = Action.limit(5)

    respond_to do |format|
      format.json { render :json => @actions }
    end
  end

  def new
    @action = Action.new

    respond_to do |format|
      format.json { render :json => @action }
    end
  end

  def create
    @action = Action.new params[:action]

    respond_to do |format|
      if @action.save
        format.json { render :json => @action.to_json(:include => :attributes), :status => :created }
      else
        format.json { render :json => @action.errors.to_json }
      end
    end
  end
end
