require 'spec_helper'

describe ImagesController do
  before(:each) do
    @image = mock_model(Image, :image => "image.png")
    @image.stub!(:as_jquery_upload_response).and_return({ :id => @image.id, :image => @image.image })
  end

  context "#index" do
    it 'should give all the images' do
      Image.stub!(:all).and_return([@image])

      get :index

      response.should be_success
      response.body.should eql([{:id => @image.id, :image => @image.image }].to_json)
    end
  end

  context "#show" do
    it 'should give image of a scene' do
      scene = mock_model(Scene, :images => Image)
      image = Factory(:image)
      Scene.should_receive(:find).with(scene.id.to_s).and_return(scene)
      Image.should_receive(:find).with(image.id.to_s).and_return(image)

      get :show, :scene_id => scene.id, :id => image.id, :format => :json
      response.body.should eql(image.to_json)
    end
  end

  context "#create" do
    before(:each) do
      @image_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/350x350.png'), 'image/png')
    end

    it 'should create one single image' do
      controller.should_receive(:write_file).and_return(@image_file)
      Image.should_receive(:create).and_return(@image)

      post :create, :base64 => '1', :image => { :files => [@image_file] }, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @image.id, :image => @image.image }].to_json)
    end

    it 'should create multiple images' do
      Image.should_receive(:create).exactly(2).times.and_return(@image)

      post :create, :image => { :files => [@image_file, @image_file] }, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @image.id, :image => @image.image }, { :id => @image.id, :image => @image.image }].to_json)
    end
  end

  context "#update" do
    before(:each) do
      @image_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/350x350.png'), 'image/png')
    end

    it 'should update image' do
      Image.should_receive(:find).with(@image.id.to_s).and_return(@image)
      @image.should_receive(:remove_image!).and_return(true)
      controller.should_receive(:write_file).and_return(@image_file)
      @image.should_receive(:update_attribute).and_return(@image)

      put :update, :id => @image.id, :image => { :files => [@image_file] }, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @image.id, :image => @image.image }].to_json)
    end
  end

  context "#destroy" do
    it 'should destroy image' do
      Image.should_receive(:find).with(@image.id.to_s).and_return(@image)
      @image.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @image.id, :format => :json

      response.should be_success
    end
  end
end
