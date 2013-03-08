require 'spec_helper'

describe StorybooksController do
  before(:each) do
    @user = mock_model(User)
    @storybook = mock_model(Storybook, :title => "Some title")
    test_sign_in(@user)
  end

  context "not requiring preloaded storybook" do
    before(:each) do
      @user.should_receive(:storybooks).and_return(Storybook)
    end

    context '#index' do
      it "should give all storybooks of the current user" do
        Storybook.should_receive(:all).and_return([@storybook])
        @storybook.stub(:as_json).and_return({ :id => @storybook.id, :title => @storybook.title })
        get :index, :format => :json

        response.should be_success
        response.body.should eql([{ :id => @storybook.id, :title => @storybook.title }].to_json)
      end
    end

    context '#create' do
      before(:each) do
        Storybook.should_receive(:new).with('title' => 'Some title').and_return(@storybook)
      end

      it 'should create a storybook for current user' do
        @storybook.should_receive(:save).and_return(true)
        @storybook.stub(:as_json).and_return({ :id => @storybook.id, :title => @storybook.title })

        post :create, :storybook => { :title => 'Some title' }, :format => :json

        response.code.should eql('201')
        response.body.should eql({ :id => @storybook.id, :title => @storybook.title }.to_json)
      end

      it 'should not create a storybook for invalid data' do
        errors = { :error => 'some error' }
        @storybook.should_receive(:save).and_return(false)
        @storybook.stub(:errors).and_return(errors)

        post :create, :storybook => { :title => 'Some title' }, :format => :json

        response.should_not be_success
        response.body.should eql(errors.to_json)
      end
    end
  end

  context "requiring preloaded storybook" do
    before(:each) do
      @user.should_receive(:storybooks).and_return(Storybook)
      Storybook.should_receive(:find).with(@storybook.id.to_s).and_return(@storybook)
    end

    context '#show' do
      it "shows a storybook" do
        @storybook.stub(:as_json).and_return(:id => @storybook.id, :title => @storybook.title)

        get :show, :id => @storybook.id, :format => :json

        response.should be_success
        response.body.should eql({ :id => @storybook.id, :title => @storybook.title }.to_json)
      end
    end

    context '#update' do
      it 'updates the storybook' do
        @storybook.should_receive(:update_attributes).with('title' => 'Some other title', 'id' => @storybook.id.to_s).and_return(true)
        @storybook.stub(:as_json).and_return(:id => @storybook.id, :title => 'Some other title')

        put :update, :id => @storybook.id, :title => 'Some other title', :format => :json

        response.should be_success
        response.body.should eql({ :id => @storybook.id, :title => 'Some other title' }.to_json)
      end

      it 'does not update invalid storybook' do
        errors = { :error => 'some error' }
        @storybook.should_receive(:update_attributes).with('title' => 'Some other title', 'id' => @storybook.id.to_s).and_return(false)
        @storybook.stub(:errors).and_return(errors)

        put :update, :id => @storybook.id, :title => 'Some other title', :format => :json

        response.should_not be_success
        response.body.should eql(errors.to_json)
      end
    end

    context '#destroy' do
      it 'destroys the storybook' do
        @storybook.should_receive(:destroy).and_return(true)

        delete :destroy, :id => @storybook.id, :format => :json

        response.should be_success
      end
    end
  end
end
