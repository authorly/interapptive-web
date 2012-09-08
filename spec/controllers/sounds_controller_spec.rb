require 'spec_helper'

describe SoundsController do
  before(:each) do
    @sound = mock_model(Sound, :sound => "sound.wav")
    @sound.stub!(:as_jquery_upload_response).and_return({ :id => @sound.id, :sound => @sound.sound })
    user = Factory(:user)
    test_sign_in(user)
  end

  context "#index" do
    it 'should give all the sounds' do
      storybook = Factory(:storybook)
      Sound.stub!(:where).with(:storybook_id => storybook.id.to_s).and_return([@sound])

      get :index, :storybook_id => storybook.id

      response.should be_success
      response.body.should eql([{:id => @sound.id, :sound => @sound.sound }].to_json)
    end
  end

  context "#create" do
    it 'should create multiple sounds' do
      fake_sound = "sound.wav"
      storybook = Factory(:storybook)
      Sound.should_receive(:create).with(:sound => fake_sound, :storybook_id => storybook.id).exactly(2).times.and_return(@sound)

      post :create, :sound => { :files => [fake_sound, fake_sound] }, :storybook_id => storybook.id, :format => :json

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
