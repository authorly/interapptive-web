require 'spec_helper'

describe TermsController do
  before(:each) do
    @user = mock_model(User)
    test_sign_in(@user)
  end

  context '#create' do
    context "user does not accept terms" do
      it 'should ask for accepting terms again' do
        post :create, :terms => 'off'

        response.should redirect_to(new_term_url)
      end
    end

    context "user accepts terms" do
      it 'should redirect to storybooks listing page' do
        @user.should_receive(:update_attribute).with(:accepted_terms, true).and_return(true)
        post :create, :terms => 'on'
        response.should redirect_to(storybooks_url)
      end
    end
  end
end
