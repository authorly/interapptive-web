require 'spec_helper'


describe KeyframesController do
  before(:each) do
    @user = mock_model(User, :id => 1)
    @storybook = mock_model(Storybook, :id => 1)
    @scene = mock_model(Scene, :id => 1, :storybook => @storybook)
    @keyframe = mock_model(Keyframe, :id => 1)
    Scene.stub(:find).with(@scene.id.to_s).and_return(@scene)
    @storybook.stub(:owned_by?).with(@user).and_return(true)
    test_sign_in(@user)
  end


  context '#index' do
    it 'should return keyframes json in scene' do
      @scene.should_receive(:keyframes).and_return([@keyframe])
      @keyframe.stub(:as_json).and_return({ :id => @keyframe.id })

      get :index, :scene_id => @scene.id, :format => :json

      response.should be_success
      response.body.should eql([{ :id => @keyframe.id }].to_json)
    end
  end

  context '#show' do
    it 'should render json of a keyframe' do
      @scene.should_receive(:keyframes).and_return(Keyframe)
      Keyframe.should_receive(:find).with(@keyframe.id.to_s).and_return(@keyframe)
      @keyframe.stub(:as_json).and_return({ :id => @keyframe.id })

      get :show, :scene_id => @scene.id, :id => @keyframe.id, :format => :json

      response.should be_success
      response.body.should eql({ :id => @keyframe.id }.to_json)
    end
  end

  context '#create' do
    before(:each) do
      @scene.should_receive(:keyframes).and_return(Keyframe)
      Keyframe.should_receive(:new).with('scene_id' => @scene.id).and_return(@keyframe)
    end

    it 'should create a new keyframe for the scene in question' do
      @keyframe.should_receive(:save).and_return(true)
      @keyframe.stub(:as_json).and_return({ :id => @keyframe.id })

      post :create, :scene_id => @scene.id, :keyframe => { :scene_id => @scene.id }, :format => :json

      response.should be_success
      response.body.should eql({ :id => @keyframe.id }.to_json)
    end

    it 'should not create a keyframe if invalid' do
      errors = { :error => 'some error' }
      @keyframe.should_receive(:save).and_return(false)
      @keyframe.stub(:errors).and_return(errors)

      post :create, :scene_id => @scene.id, :keyframe => { :scene_id => @scene.id }, :format => :json

      response.should_not be_success
      response.body.should eql(errors.to_json)
    end
  end

  context '#update' do
    before(:each) do
      @scene.should_receive(:keyframes).and_return(Keyframe)
      Keyframe.should_receive(:find).with(@keyframe.id.to_s).and_return(@keyframe)
    end

    it 'should update a keyframe for the scene in question' do
      @keyframe.should_receive(:update_attributes).with('scene_id' => @scene.id).and_return(true)
      @keyframe.stub(:as_json).and_return({ :id => @keyframe.id })

      put :update, :scene_id => @scene.id, :id => @keyframe.id, :keyframe => { :scene_id => @scene.id }, :format => :json

      response.should be_success
      response.body.should eql({ :id => @keyframe.id }.to_json)
    end

    it 'should not update a keyframe if invalid' do
      errors = { :error => 'some error' }
      @keyframe.should_receive(:update_attributes).with('scene_id' => @scene.id).and_return(false)
      @keyframe.stub(:errors).and_return(errors)

      put :update, :scene_id => @scene.id, :id => @keyframe.id, :keyframe => { :scene_id => @scene.id }, :format => :json

      response.should_not be_success
      response.body.should eql(errors.to_json)
    end
  end

  context '#destroy' do
    before(:each) do
      @scene.should_receive(:keyframes).and_return(Keyframe)
      Keyframe.should_receive(:find).with(@keyframe.id.to_s).and_return(@keyframe)
    end

    it 'should destroy a keyframe' do
      @keyframe.should_receive(:destroy).and_return(true)

      delete :destroy, :scene_id => @scene.id, :id => @keyframe.id, :format => :json

      response.should be_success
    end
  end

  context '#sort' do
    it 'should update the position of keyframes' do
      @keyframe2 = mock_model(Keyframe, :id => 2)

      keyframes = mock()
      keyframes.should_receive(:find).with(@keyframe.id).once.and_return(@keyframe)
      keyframes.should_receive(:find).with(@keyframe2.id).once.and_return(@keyframe2)

      @scene.should_receive(:keyframes).twice.and_return(keyframes)

      @keyframe.should_receive(:position=).with(1).once
      @keyframe2.should_receive(:position=).with(2).once
      @keyframe.should_receive(:save).with(:validate => false).once.and_return(true)
      @keyframe2.should_receive(:save).with(:validate => false).once.and_return(true)

      post :sort, :scene_id => @scene.id, :keyframes => [{ :id => @keyframe.id, :position => 1}, { :id => @keyframe2.id, :position => 2}], :format => :json

      response.should be_success
    end
  end
end
