require 'spec_helper'

describe AssetsController do

  context "#create" do
    it 'should not crash if no files are received #1295' do
      storybook = Factory(:storybook)
      test_sign_in(storybook.user)
      post :create, :storybook_id => storybook.id, :format => :json

      response.should be_success
    end
  end

end
