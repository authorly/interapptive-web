class SubscriptionPublishInformationsController < ApplicationController
  respond_to :json

  def update
    storybook = signed_in_as_user.storybooks.find(params[:storybook_id])
    respond_to do |format|
      if storybook.update_attributes(cover_image_id: params[:cover_image_id])
        format.json { render json: { cover_image_id: storybook.cover_image_id } }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end
end
