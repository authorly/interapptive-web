class FontsController < ApplicationController
  before_filter :authorize

  def index
    fonts = Font.where(:storybook_id => params[:storybook_id])

    render :json => fonts.map(&:as_jquery_upload_response).to_json
  end

  def create
    storybook = Storybook.find params[:storybook_id]

    fonts = params[:font][:files].map { |f| Font.create(:font => f, :storybook_id => storybook.id) }
    
    respond_to do |format|
      format.json { render :json => fonts.map(&:as_jquery_upload_response).to_json }
    end
  end

  # DELETE /fonts/:id.json
  def destroy
    Font.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
