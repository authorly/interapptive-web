require 'spec_helper'

describe SoundsController do
  before(:each) do
    @scene = Factory(:scene)
    @sound = mock_model(Sound, :sound => "sound.wav")
    @sound.stub!(:as_jquery_upload_response).and_return({ :id => @sound.id, :sound => @sound.sound })
  end

  context "#index" do
    it 'should give all the sounds' do
      Sound.stub!(:all).and_return([@sound])

      get :index

      response.should be_success
      response.body.should eql([{:id => @sound.id, :sound => @sound.sound }].to_json)
    end
  end

  context "#create" do
    it 'should create multiple sounds' do
      fake_sound = "sound.wav"
      # need unique sounds
      @sound1 = Factory(:sound, :id => 1)
      Sound.should_receive(:create).with(:sound => fake_sound).exactly(2).times.and_return(@sound)

      post :create, :sound => { :files => [fake_sound, fake_sound] }, :scene_id => @scene.id, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @sound.id, :sound => @sound.sound }, { :id => @sound.id, :sound => @sound.sound }].to_json)
    end
  end

  context "#destroy" do
    it 'should destroy sound' do
      Sound.should_receive(:find).with(@sound.id.to_s).and_return(@sound)
      @sound.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @sound.id, :format => :json

      response.should be_success
    end
  end
end
