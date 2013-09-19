class AssetsController < ApplicationController
  before_filter :find_storybook

  def create
    assets = params[:files].map{ |file| Asset.create_asset(@storybook, file) }.compact
    respond_to do |format|
      format.json { render :json => assets.map(&:as_jquery_upload_response).to_json }
    end
  end

  private

  def find_storybook
    @storybook = signed_in_as_user.storybooks.find(params[:storybook_id])
  end

end
