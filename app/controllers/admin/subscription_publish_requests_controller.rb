module Admin
  class SubscriptionPublishRequestsController < Admin::BaseController

    def index
      @review_required  = SubscriptionPublishRequest.where('status = ?', SubscriptionPublishRequest::STATUSES[:review_required]).order('updated_at DESC')
      @published        = SubscriptionPublishRequest.where('status = ?', SubscriptionPublishRequest::STATUSES[:published]).order('updated_at DESC')
      @ready_to_publish = SubscriptionPublishRequest.where('status = ?', SubscriptionPublishRequest::STATUSES[:ready_to_publish]).order('updated_at DESC')

      respond_to do |format|
        format.html
      end
    end
  end
end
