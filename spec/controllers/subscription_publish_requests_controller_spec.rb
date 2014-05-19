require 'spec_helper'

describe SubscriptionPublishRequestsController do
  before :all do
    @storybook = Factory.create(:storybook)
    @user = Factory.create(:user)
    @storybook.update_attribute(:user_id, @user.id)
  end

  describe '#create' do
    it 'should create a subscription publish request for a storybook' do
      Storybook.any_instance.should_receive(:create_or_update_subscription_publish_request)
      test_sign_in(@storybook.user)

      post :create, :storybook_id => @storybook.id, :format => :json
      response.should be_success
    end
  end
end
