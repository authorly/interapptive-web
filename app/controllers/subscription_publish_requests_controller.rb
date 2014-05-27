class SubscriptionPublishRequestsController < ApplicationController

  def create
    storybook = signed_in_as_user.storybooks.find(params[:storybook_id])

    storybook.create_or_update_subscription_publish_request
    KMTS.record(current_user.email, "Submitted app for publishing")
    respond_to do |format|
      format.json { render json: storybook.subscription_publish_request }
    end
  end
end
