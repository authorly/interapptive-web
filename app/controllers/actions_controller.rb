class ActionsController < ApplicationController
  def index
    @actions = Action.limit(5)

    respond_to do |format|
      format.js
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
        format.json { render :json @action.errors.to_json }
      end
    end
  end
end
