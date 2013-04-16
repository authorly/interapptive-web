require 'spec_helper'

describe ImagesController do
  before(:each) do
    @user = Factory(:user)
    @storybook = Factory(:storybook, user: @user)
    @image = mock_model(Image, :image => "image.png")
    @image.stub!(:as_jquery_upload_response).and_return({ :id => @image.id, :image => @image.image })
    test_sign_in(@user)
  end

  context "#index" do
    it 'should give all the images of storybook' do
      @storybook = Factory(:storybook)
      @user.stub(:storybooks).and_return(Storybook)
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      @storybook.stub(:images).and_return(Image)
      Image.stub!(:where).with(:generated => false).and_return([@image])
      get :index, :storybook_id => @storybook.id

      response.should be_success
      response.body.should eql([{:id => @image.id, :image => @image.image }].to_json)
    end
  end

  context "#show" do
    it 'should give image of a scene' do
      scene = mock_model(Scene, :images => Image, :storybook => @storybook)
      @storybook.stub(:owned_by?).with(@user).and_return(true)
      image = Factory(:image)
      Scene.should_receive(:find).with(scene.id.to_s).and_return(scene)
      Image.should_receive(:find).with(image.id.to_s).and_return(image)

      get :show, :scene_id => scene.id.to_s, :id => image.id.to_s, :format => :json
      response.body.should eql(image.to_json)
    end
  end

  context "#create" do
    before(:each) do
      @image_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/350x350.png'), 'image/png')
      @storybook = Factory(:storybook)
      @user.stub(:storybooks).and_return(Storybook)
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
    end

    it 'should create one single image' do
      Image.should_receive(:create).and_return(@image)

      post :create, :base64 => '1', :image => { :files => [@image_file] }, :storybook_id => @storybook.id, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @image.id, :image => @image.image }].to_json)
    end

    it 'should create multiple images' do
      Image.should_receive(:create).exactly(2).times.and_return(@image)

      post :create, :image => { :files => [@image_file, @image_file] }, :storybook_id => @storybook.id, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @image.id, :image => @image.image }, { :id => @image.id, :image => @image.image }].to_json)
    end
  end

  context "#update" do
    before(:each) do
      @image = Factory(:image, storybook: @storybook)
      @data = Base64.encode64 File.read(Rails.root.join('spec/factories/images/350x350.png'))
    end

    it 'should update image' do
      put :update, :id => @image.id, :data_url => @data, :format => :json

      response.should be_success
      JSON.parse(response.body)["url"].should be
    end
  end

  context "#destroy" do
    it 'should destroy image' do
      Image.should_receive(:find).with(@image.id.to_s).and_return(@image)
      @image.stub(:storybook).and_return(@storybook)
      @storybook.stub(:owned_by?).and_return(true)
      @image.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @image.id, :format => :json

      response.should be_success
    end
  end
end
