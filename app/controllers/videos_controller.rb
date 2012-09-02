class VideosController < ApplicationController
  def index
    @videos = Video.all

    render :json => @videos.collect { |p| p.as_jquery_upload_response }.to_json
  end

  def create
    @scene = Scene.find params[:scene_id]
    
    @videos = params[:video][:files].map { |f| Video.create(:video => f) }
    @videos.each do |i|
      @scene.videos << i
    end
  
    respond_to do |format|
      puts "------------"
      puts @videos.map(&:as_jquery_upload_response).to_json
      format.json { render :json => @videos.map(&:as_jquery_upload_response).to_json }
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