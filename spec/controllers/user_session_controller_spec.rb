require 'spec_helper'

describe UserSessionsController do
  before(:each) do
    @user = mock_model(User)
  end

  context '#create' do
    it 'should sign a user in' do
      User.should_receive(:find_by_email_and_is_deleted).with('foo@bar.com', false).and_return(@user)
      @user.should_receive(:authenticate).with('foo').and_return(true)
      @user.stub(:auth_token).and_return('blah')
      @user.stub(:is_admin?).and_return(false)
      KMTS.should_receive(:alias).and_return(true)

      post :create, :email => 'foo@bar.com', :password => 'foo'
      response.should be_redirect
    end

    it 'should not sign a user in when not authenticated' do
      User.should_receive(:find_by_email_and_is_deleted).with('foo@bar.com', false).and_return(@user)
      @user.should_receive(:authenticate).with('foo').and_return(false)
      post :create, :email => 'foo@bar.com', :password => 'foo'
      response.should render_template(:new)
    end

    it 'should not sign a user in when not found' do
      User.should_receive(:find_by_email_and_is_deleted).with('foo@bar.com', false).and_return(nil)
      post :create, :email => 'foo@bar.com', :password => 'foo'
      response.should render_template(:new)
    end
  end
end
