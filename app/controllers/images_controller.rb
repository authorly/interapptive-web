class ImagesController < ApplicationController
  def create
    @images = params[:files].map { |f| Image.create(:image => f) }

    respond_to do |format|
      format.json do
        # IE workaround: https://github.com/blueimp/jQuery-File-Upload/issues/123
        opts = (request.headers["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest") ? {} : {:content_type => "text/html"}
        json = @images.map(&:as_jquery_upload_response).to_json
        format.json { render :json => json.merge(opts) }
      end
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
