require 'spec_helper'

describe SubscriptionPublishRequest do
  let!(:subscription_publish_request) { Factory(:subscription_publish_request) }

  describe '#review_required?' do
    context "when status is 'review-required'" do
      it 'should be true' do
        subscription_publish_request.update_attribute(:status, SubscriptionPublishRequest::STATUSES[:review_required])
        expect(subscription_publish_request.review_required?).to be
      end
    end

    context "when status is not 'review-required'" do
      it 'should be false' do
        subscription_publish_request.update_attribute(:status, SubscriptionPublishRequest::STATUSES[:published])
        expect(subscription_publish_request.review_required?).not_to be
        subscription_publish_request.update_attribute(:status, SubscriptionPublishRequest::STATUSES[:ready_to_publish])
        expect(subscription_publish_request.review_required?).not_to be
      end
    end
  end
end
