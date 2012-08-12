require 'spec_helper'

describe FontsController do
  before(:each) do
    @font = mock_model(Font, :font => "font.ttf")
    @font.stub!(:as_jquery_upload_response).and_return({ :id => @font.id, :font => @font.font })
  end

  context "#index" do
    it 'should give all the fonts' do
      Font.stub!(:all).and_return([@font])

      get :index

      response.should be_success
      response.body.should eql([{:id => @font.id, :font => @font.font }].to_json)
    end
  end

  context "#create" do
    it 'should create multiple fonts' do
      fake_font = "font.wav"

      Font.should_receive(:create).with(:font => fake_font).exactly(2).times.and_return(@font)

      post :create, :font => { :files => [fake_font, fake_font] }, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @font.id, :font => @font.font }, { :id => @font.id, :font => @font.font }].to_json)
    end
  end

  context "#destroy" do
    it 'should destroy font' do
      Font.should_receive(:find).with(@font.id.to_s).and_return(@font)
      @font.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @font.id, :format => :json

      response.should be_success
    end
  end
end
