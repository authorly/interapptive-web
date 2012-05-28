class ActionDefinitionsController < ApplicationController
  def index
    @action_definitions = ActionDefinition.includes(:attribute_definitions).all

    respond_to do |format|
      format.json { render :json => @action_definitions.to_json(:include => :attribute_definitions) }
    end
  end
end
