class VideosController < ApplicationController
  before_filter :find_storybook, :except => :destroy

  def index
    videos = @storybook.videos
    videos = videos.where(id: params[:video_ids]) if params[:video_ids].present?

    render :json => videos.map(&:as_jquery_upload_response).to_json
  end

  def create
    videos = params[:video][:files].map { |f| Video.create(:video => f, :storybook_id => @storybook.id) }

    respond_to do |format|
      format.json { render :json => videos.map(&:as_jquery_upload_response).to_json }
    end
  end

  def destroy
    video = Video.find(params[:id])
    raise ActiveRecord::RecordNotFound unless video.storybook.owned_by?(signed_in_as_user)
    video.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end

  private

  def find_storybook
    @storybook = signed_in_as_user.storybooks.find(params[:storybook_id])
  end
end
