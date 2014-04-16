class SimulatorController < ApplicationController
  layout false

  def show
  end

  def main
    @storybook = signed_in_as_user.storybooks.find params[:storybook_id]
  end
end
