require 'spec_helper'

describe VideosController do
  before(:each) do
    @video = mock_model(Video, :video => "video.avi")
    @storybook = mock_model(Storybook)
    @video.stub!(:as_jquery_upload_response).and_return({ :id => @video.id, :video => @video.video })
    @user = Factory(:user)
    test_sign_in(@user)
  end

  context "#index" do
    it 'should give all the videos' do
      @user.stub(:storybooks).and_return(Storybook)
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      @storybook.stub(:videos).and_return([@video])

      get :index, :storybook_id => @storybook.id

      response.should be_success
      response.body.should eql([{:id => @video.id, :video => @video.video }].to_json)
    end
  end

  context "#create" do
    it 'should create multiple videos' do
      fake_video = "video.wmv"
      @user.stub(:storybooks).and_return(Storybook)
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      Video.should_receive(:create).with(:video => fake_video, :storybook_id => @storybook.id).exactly(2).times.and_return(@video)

      post :create, :video => { :files => [fake_video, fake_video] }, :storybook_id => @storybook.id, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @video.id, :video => @video.video }, { :id => @video.id, :video => @video.video }].to_json)
    end
  end

  context "#destroy" do
    it 'should destroy video' do
      Video.should_receive(:find).with(@video.id.to_s).and_return(@video)
      @video.stub(:storybook).and_return(@storybook)
      @storybook.stub(:owned_by?).with(@user).and_return(true)
      @video.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @video.id, :format => :json

      response.should be_success
    end
  end
end
