require 'spec_helper'

describe KeyframeAudiosController do
  before(:each) do
    @user = mock_model(User, :id => 1)
    @storybook = mock_model(Storybook, :id => 1)
    @scene = mock_model(Scene, :id => 1, :storybook => @storybook)
    @keyframe = mock_model(Keyframe, :id => 1, :scene => @scene)

    Keyframe.should_receive(:find).with(@keyframe.id.to_s).and_return(@keyframe)
    @storybook.stub(:owned_by?).with(@user).and_return(true)
    test_sign_in(@user)
  end

  context '#show' do
    it 'should show audio as jquery upload response of the keyframe' do
      @keyframe.stub(:audio_as_jquery_upload_response).and_return({ :id => @keyframe.id })

      get :show, :keyframe_id => @keyframe.id, :format => :json

      response.should be_success
      response.body.should eql({:id => @keyframe.id}.to_json)
    end
  end

  context '#update' do
    it 'should successfully return the transcript' do
      @keyframe.should_receive(:save_and_sync_text).and_return(['blah blah'])

      put :update, :keyframe_id => @keyframe.id, :format => :json

      response.should be_success
      response.body.should eql(['blah blah'].to_json)
    end

    it 'should error on unsuccessful transcript' do
      @keyframe.should_receive(:save_and_sync_text).and_return([])

      put :update, :keyframe_id => @keyframe.id, :format => :json

      response.should_not be_success
      response.body.should eql({ :audio => "Unprocessable file" }.to_json)
    end
  end

  context '#create' do
    it 'should create add audio to the keyframe' do
      @keyframe.should_receive(:audio=).with('audio.wav').and_return('audio.wav')
      @keyframe.should_receive(:save).and_return(true)
      @keyframe.stub(:audio_as_jquery_upload_response).and_return({ :id => @keyframe.id })

      post :create, :keyframe_id => @keyframe.id, :file => 'audio.wav', :format => :json

      response.should be_success
      response.body.should eql({ :id => @keyframe.id }.to_json)
    end
  end
end
