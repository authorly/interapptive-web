require 'spec_helper'

describe ConfirmationsController do
  before(:each) do
    @user = mock_model(User)
  end

  context '#new' do
    it 'when invalid confirmation token' do
      User.should_receive(:find_by_confirmation_token).with('token').and_return(nil)

      get :new, :confirmation_token => 'token'
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("We do not have record of this email.")
    end

    it 'when user is already confirmed' do
      User.should_receive(:find_by_confirmation_token).with('token').and_return(@user)
      @user.should_receive(:confirmed?).and_return(true)

      get :new, :confirmation_token => 'token'
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("You have confirmed your email. Now use your password to Sign In.")
    end

    it 'when user is not already confirmed' do
      User.should_receive(:find_by_confirmation_token).with('token').and_return(@user)
      @user.should_receive(:confirmed?).and_return(false)

      get :new, :confirmation_token => 'token'
      expect(response).to render_template(:new)
    end
  end

  context '#create' do
    it 'when invalid confirmation token' do
      User.should_receive(:find_by_confirmation_token).with('token').and_return(nil)

      post :create, :confirmation_token => 'token'
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("We do not have record of this email.")
    end

    it 'when invalid password' do
      User.should_receive(:find_by_confirmation_token).with('token').and_return(@user)
      @user.should_receive(:password=).with('password')
      @user.should_receive(:password_confirmation=).with('password')
      @user.should_receive(:save).and_return(false)

      post :create, :confirmation_token => 'token', :password => 'password', :password_confirmation => 'password'
      expect(response).to render_template(:new)
    end

    it 'should save the password of user' do
      User.should_receive(:find_by_confirmation_token).with('token').and_return(@user)
      @user.should_receive(:password=).with('password')
      @user.should_receive(:password_confirmation=).with('password')
      @user.should_receive(:save).and_return(true)
      @user.should_receive(:confirm).and_return(true)
      @user.should_receive(:auth_token).and_return('auth_token')

      @user.stub(:is_admin?).and_return(true)

      post :create, :confirmation_token => 'token', :password => 'password', :password_confirmation => 'password'
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("You have successfully set your password.")
      expect(cookies[:auth_token]).to eq('auth_token')
      expect(cookies[:is_admin]).to be_true
    end
  end
end
