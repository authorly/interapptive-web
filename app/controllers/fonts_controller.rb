class FontsController < ApplicationController
  def index
    storybook = current_user.storybooks.find(params[:storybook_id])
    render :json => (Font.where(:asset_type => 'system').map(&:as_jquery_upload_response) +
                     storybook.fonts.map(&:as_jquery_upload_response)).to_json
  end

  def create
    storybook = current_user.storybooks.find params[:storybook_id]

    font = Font.create(:font => params[:font][:files][0], :storybook_id => storybook.id)

    respond_to do |format|
      format.json {
        if font.valid?
          render json: [font.as_jquery_upload_response].to_json
        else
          render json: font.errors[:font], status: :unprocessable_entity
        end
      }
    end
  end

  # DELETE /fonts/:id.json
  def destroy
    font = Font.where(:id => params[:id], :asset_type => 'custom').first
    raise ActiveRecord::RecordNotFound if font.blank? || !font.storybook.owned_by?(current_user)
    font.try(:destroy)

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
