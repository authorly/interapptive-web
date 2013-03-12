require 'spec_helper'

describe CompilersController do
  before :all do
    @storybook = Factory.create(:storybook)
    @user = Factory.create(:user)
    @storybook.update_attribute(:user_id, @user.id)
  end

  describe '#create' do
    it 'should enqueu storybook for compilation' do
      Storybook.any_instance.stub(:enqueue_for_compilation).and_return(true)
      Storybook.any_instance.should_receive(:enqueue_for_compilation).and_return(true)
      test_sign_in(@storybook.user)

      post :create, :storybook_id => @storybook.id, :storybook_json => '{}', :format => :json
      response.should be_success
    end
  end
end
