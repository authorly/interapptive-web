require 'spec_helper'

describe VideosController do
  before(:each) do
    @video = mock_model(Video, :video => "video.avi")
    @video.stub!(:as_jquery_upload_response).and_return({ :id => @video.id, :video => @video.video })
  end

  context "#index" do
    it 'should give all the videos' do
      Video.stub!(:all).and_return([@video])

      get :index

      response.should be_success
      response.body.should eql([{:id => @video.id, :video => @video.video }].to_json)
    end
  end

  context "#create" do
    it 'should create multiple videos' do
      fake_video = "video.wmv"

      Video.should_receive(:create).with(:video => fake_video).exactly(2).times.and_return(@video)

      post :create, :video => { :files => [fake_video, fake_video] }, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @video.id, :video => @video.video }, { :id => @video.id, :video => @video.video }].to_json)
    end
  end

  context "#destroy" do
    it 'should destroy video' do
      Video.should_receive(:find).with(@video.id.to_s).and_return(@video)
      @video.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @video.id, :format => :json

      response.should be_success
    end
  end
end
