require 'spec_helper'

describe PasswordResetsController do
  context "#new" do
    it 'should render form' do
      get :new
      response.should be_success
    end
  end

  context "#create" do
    before(:each) do
      @user = mock_model(User, :email => 'foo@bar.com')
    end

    context "if user is available" do
      it 'should create a password reset token' do
        User.stub(:find_by_email).with(@user.email).and_return(@user)
        @user.should_receive(:send_password_reset).exactly(1).times

        post :create, :email => @user.email
        response.should redirect_to(sign_in_path)
      end
    end

    context "if user is not available" do
      it 'should not create a password reset token' do
        User.stub(:find_by_email).with('fakeemail').and_return(nil)
        @user.should_not_receive(:send_password_reset)

        post :create, :email => 'fakeemail'
        response.should redirect_to(sign_in_path)
      end
    end
  end

  context "#edit" do
    it 'should be successful' do
      User.should_receive(:find_by_password_reset_token!).with('SomeCrypticToken').exactly(1).times
      get :edit, :id => "SomeCrypticToken"
      response.should be_success
    end
  end

  context "#update" do
    before(:each) do
      @user = mock_model(User, :email => 'foo@bar.com', :password_reset_token => "SomeCrypticToken")
      User.should_receive(:find_by_password_reset_token!).
        with(@user.password_reset_token).
        exactly(1).
        times.
        and_return(@user)
    end

    context "if reset token is more than two hours old" do
      it 'should ask user to regenrate token' do
        @user.stub(:password_reset_sent_at).and_return(3.hours.ago)
        put :update, :id => @user.password_reset_token

        response.should redirect_to(new_password_reset_path)
      end
    end

    context "if password submitted is blank" do
      it 'should ask user to submit password again' do
        @user.stub(:password_reset_sent_at).and_return(1.hours.ago)
        put :update, :id => @user.password_reset_token, :user => { :password => '', :password_confirmation => '' }

        response.should redirect_to(edit_password_reset_path)
      end
    end

    context "if password is updated" do
      it 'should take user to root' do
        @user.stub(:password_reset_sent_at).and_return(1.hours.ago)
        @user.should_receive(:update_attributes).
          with(:password => 'tester', :password_confirmation => 'tester').
          and_return(true)

        put :update, :id => @user.password_reset_token, :user => { :password => 'tester', :password_confirmation => 'tester' }
        response.should redirect_to(root_path)
      end
    end

    context "if password is not updated" do
      it 'should ask user to enter password again' do
        @user.stub(:password_reset_sent_at).and_return(1.hours.ago)
        @user.should_receive(:update_attributes).
          with(:password => 'tester', :password_confirmation => 'tester').
          and_return(false)

        put :update, :id => @user.password_reset_token, :user => { :password => 'tester', :password_confirmation => 'tester' }
        response.should be_success
        response.should render_template(:edit)
      end
    end
  end
end
