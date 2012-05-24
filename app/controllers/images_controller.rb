class ImagesController < ApplicationController
  def index
    # TODO: Associate image with current_user and scene
    @images = Image.all

    render :json => @images.collect { |p| p.as_jquery_upload_response }.to_json
  end

  def create
    attr = params[:image]
    attr[:image] = params[:image][:image].first if params[:image][:image].class == Array

    @image = Image.new(attr)

    if @image.save
      respond_to do |format|
        format.html {
          render :json => [@image.as_jquery_upload_response].to_json,
                 :content_type => 'text/html',
                 :layout => false
        }
        format.json {
          render :json => [@image.as_jquery_upload_response].to_json
        }
      end
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  # DELETE /images/:id.json
  def destroy
    Image.find(params[:id]).try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
