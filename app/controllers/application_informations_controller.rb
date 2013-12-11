class ApplicationInformationsController < ApplicationController
  respond_to :json

  before_filter :find_storybook

  # Backbone.js extraneous parameter hack
  param_protected [:action, :controller, :format, :storybook], :only => :update

  def create
    update
  end

  def update
    information = @storybook.application_information || @storybook.build_application_information
    information.attributes = params[:application_information]
    respond_to do |format|
      if information.save
        @storybook.publish
        format.json { render :json => information}
      else
        format.json { render :json => information.errors, :status => :unprocessable_entity }
      end
    end
  end
  private

  def find_storybook
    @storybook = signed_in_as_user.storybooks.find params[:storybook_id]
  end
end

