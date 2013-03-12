require 'spec_helper'

describe UserSessionsController do
  before(:each) do
    @user = mock_model(User)
  end

  context '#create' do
    it 'should sign a user in' do
      User.should_receive(:find_by_email).with('foo@bar.com').and_return(@user)
      @user.should_receive(:authenticate).with('foo').and_return(true)
      @user.stub(:auth_token).and_return('blah')

      post :create, :email => 'foo@bar.com', :password => 'foo'
      response.should be_redirect
    end

    it 'should not sign a user in when not authenticated' do
      User.should_receive(:find_by_email).with('foo@bar.com').and_return(@user)
      @user.should_receive(:authenticate).with('foo').and_return(false)
      post :create, :email => 'foo@bar.com', :password => 'foo'
      response.should render_template(:new)
    end

    it 'should not sign a user in when not found' do
      User.should_receive(:find_by_email).with('foo@bar.com').and_return(nil)
      post :create, :email => 'foo@bar.com', :password => 'foo'
      response.should render_template(:new)
    end
  end
end
