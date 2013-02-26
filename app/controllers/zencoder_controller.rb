class ZencoderController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authorize

  def create
    video = Video.find_by_id(params[:job][:pass_through])
    if video && params[:job][:state] == 'finished'
      video.meta_info[:response] = params[:zencoder]
      video.save
    end

    render :nothing => true
  end
end
