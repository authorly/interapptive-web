require "base64"

class VideosController < ApplicationController
  def index
    videos = Video.where(:storybook_id => params[:storybook_id])

    render :json => videos.map(&:as_jquery_upload_response).to_json
  end

  def create
    storybook = Storybook.find params[:storybook_id]
    videos = params[:video][:files].map { |f| Video.create(:video => f, :storybook_id => storybook.id) }

    respond_to do |format|
      format.json { render :json => videos.map(&:as_jquery_upload_response).to_json }
    end
  end

  # DELETE /videos/:id.json
  def destroy
    Video.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
  
  def write_file
    filename = "#{(0..35).map{ rand(36).to_s(36) }.join}.png" # Random alphanumeric
    file = File.open(filename, "wb")
    file.write(Base64.decode64(params[:video][:files][0]))
  end
end
