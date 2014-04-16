require 'spec_helper'

describe FontsController do
  before(:each) do
    @font = mock_model(Font, :font => "font.ttf")
    @storybook = mock_model(Storybook)
    @font.stub!(:as_jquery_upload_response).and_return({ :id => @font.id, :font => @font.font })
    @user = Factory(:user)
    test_sign_in(@user)
  end

  context "#index" do
    it 'should give all the fonts' do
      @user.stub(:storybooks).and_return(Storybook)
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      @storybook.stub(:all_fonts).and_return([@font])

      get :index, :storybook_id => @storybook.id

      response.should be_success
      response.body.should eql([{:id => @font.id, :font => @font.font }].to_json)
    end
  end

  context "#create" do
    it 'should create a font' do
      fake_font = "font.wav"
      @user.stub(:storybooks).and_return(Storybook)
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      Font.should_receive(:create).with({:font => fake_font, :storybook_id => @storybook.id }).exactly(1).times.and_return(@font)

      post :create, :font => { :files => [fake_font] }, :storybook_id => @storybook.id, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @font.id, :font => @font.font }].to_json)
    end

    # it 'should create multiple fonts' do
      # fake_font = "font.wav"
      # @user.stub(:storybooks).and_return(Storybook)
      # Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      # Font.should_receive(:create).with({:font => fake_font, :storybook_id => @storybook.id }).exactly(2).times.and_return(@font)

      # post :create, :font => { :files => [fake_font, fake_font] }, :storybook_id => @storybook.id, :format => :json

      # response.should be_success
      # response.body.should eql([{ :id => @font.id, :font => @font.font }, { :id => @font.id, :font => @font.font }].to_json)
    # end
  end

  context "#destroy" do
    it 'should destroy font' do
      Font.should_receive(:where).with(:id => @font.id.to_s, :asset_type => 'custom').and_return([@font])
      @font.stub(:storybook).and_return(@storybook)
      @storybook.stub(:owned_by?).with(@user).and_return(true)
      @font.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @font.id, :format => :json

      response.should be_success
    end
  end
end
