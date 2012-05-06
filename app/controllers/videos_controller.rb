class VideosController < ApplicationController
  def index
    @videos = Video.limit(5)

    respond_to do |format|
      format.js
    end
  end
end
