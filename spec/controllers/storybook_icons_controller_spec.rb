require 'spec_helper'


describe StorybookIconsController do
  before(:each) do
    @user = mock_model(User, :id => 1)
    @storybook = mock_model(Storybook, :id => 1)
    @image = mock_model(Image, :id => 1, :url => 'some url')
    test_sign_in(@user)
  end

  context '#create' do
    before(:each) do
      @user.should_receive(:storybooks).and_return(Storybook)
      Storybook.should_receive(:find).with(@storybook.id.to_s).and_return(@storybook)
      @storybook.should_receive(:images).and_return(Image)
      Image.should_receive(:find).with(@image.id).and_return(@image)
      @image.stub(:image).and_return(@image)
      @storybook.should_receive(:remote_icon_url=).with(@image.url)
    end

    it 'should create icons for a storybook' do
      @storybook.should_receive(:save).and_return(true)

      post :create, :storybook_id => @storybook.id, :image_id => @image.id, :format => :json

      response.should be_success
    end
    it 'should not create icons for invalud storybook' do
      @storybook.should_receive(:save).and_return(false)

      post :create, :storybook_id => @storybook.id, :image_id => @image.id, :format => :json

      response.should_not be_success
      response.body.should eql({:icon => 'Something went wrong. We could not save your icon'}.to_json)
    end
  end
end
