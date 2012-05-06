class ActionsController < ApplicationController
  def index
    @actions = Action.limit(5)

    respond_to do |format|
      format.js
    end
  end
end
