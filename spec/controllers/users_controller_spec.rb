require 'spec_helper'

describe UsersController do
  before(:each) do
    @user = mock_model(User)
  end

  context 'actions requiring user sign in' do
    before(:each) do
      test_sign_in(@user)
    end

    context '#show' do
      it 'should render a user' do
        @user.stub(:as_json).and_return(:id => @user.id)
        get :show, :format => :json
        response.should be_success
        response.body.should eql({ :id => @user.id }.to_json)
      end
    end

    context '#edit' do
      it 'should return user edit form' do
        get :edit
        response.should be_success
      end
    end

    context '#update' do
      it 'should update a user' do
        @user.should_receive(:update_attributes).with('email' => 'foo@bar.com', 'password' => 'foo', 'password_confirmation' => 'foo').and_return(true)
        put :update, :user => { :email => 'foo@bar.com', :password => 'foo', :password_confirmation => 'foo' }, :format => :json
        response.should be_success
      end

      it 'should not update a user with invalid data' do
        errors = { :error => 'some error' }
        @user.should_receive(:update_attributes).with('email' => 'foo@bar.com', 'password' => 'foo', 'password_confirmation' => 'foo').and_return(false)
        @user.stub(:errors).and_return(errors)
        put :update, :user => { :email => 'foo@bar.com', :password => 'foo', :password_confirmation => 'foo', :name => 'some name' }, :format => :json
        response.should_not be_success
        response.body.should eql(errors.to_json)
      end
    end

    context '#destroy' do
      it 'should destroy a user' do
        @user.should_receive(:destroy).and_return(true)
        delete :destroy, :format => :json
        response.should be_success
      end
    end
  end

  context 'actions not requiring user sign in' do
    context '#new' do
      it 'should render a new user form' do
        User.should_receive(:new).and_return(@user)
        get :new
        response.should be_success
      end
    end

    context '#create' do
      before(:each) do
        User.should_receive(:new).with('email' => 'foo@bar.com').and_return(@user)
      end

      it 'should create a new user form' do
        @user.should_receive(:save).and_return(true)
        @user.stub(:auth_token).and_return('blah')

        post :create, :user => { :email => 'foo@bar.com' }
        response.should be_redirect
      end

      it 'should not create a user with invalid data' do
        @user.should_receive(:save).and_return(false)
        post :create, :user => { :email => 'foo@bar.com' }
        response.should_not be_redirect
      end
    end
  end
end
