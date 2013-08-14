class ZencoderController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authorize, :http_authorize

  def create
    video = Video.find_by_id(params[:job][:pass_through])
    video.store_transcoding_result(params[:zencoder])
    render :nothing => true
  end
end
