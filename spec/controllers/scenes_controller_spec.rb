require 'spec_helper'


describe ScenesController do
  before(:each) do
    @user = mock_model(User, :id => 1)
    @storybook = mock_model(Storybook, :id => 1)
    @scene = mock_model(Scene, :id => 1)
    test_sign_in(@user)
  end

  context 'Storybook Authorized actions' do
    before(:each) do
      Storybook.stub(:find).with(@storybook.id.to_s).and_return(@storybook)
      @storybook.stub(:owned_by?).with(@user).and_return(true)
    end

    context '#index' do
      it 'should return scenes json in scene' do
        @storybook.should_receive(:scenes).and_return([@scene])
        @scene.stub(:as_json).and_return({ :id => @scene.id })

        get :index, :storybook_id => @storybook.id, :format => :json

        response.should be_success
        response.body.should eql([{ :id => @scene.id }].to_json)
      end
    end

    context '#show' do
      it 'should render json of a scene' do
        @storybook.should_receive(:scenes).and_return(Scene)
        Scene.should_receive(:find).with(@scene.id.to_s).and_return(@scene)
        @scene.stub(:as_json).and_return({ :id => @scene.id })

        get :show, :storybook_id => @scene.id, :id => @scene.id, :format => :json

        response.should be_success
        response.body.should eql({ :id => @scene.id }.to_json)
      end
    end

    context '#create' do
      before(:each) do
        @storybook.should_receive(:scenes).and_return(Scene)
        Scene.should_receive(:new).with('storybook_id' => @storybook.id).and_return(@scene)
      end

      it 'should create a new scene for the storybook in question' do
        @scene.should_receive(:save).and_return(true)
        @scene.stub(:as_json).and_return({ :id => @scene.id })

        post :create, :storybook_id => @storybook.id, :scene => { :storybook_id => @storybook.id }, :format => :json

        response.should be_success
        response.body.should eql({ :id => @scene.id }.to_json)
      end

      it 'should not create a scene if invalid' do
        errors = { :error => 'some error' }
        @scene.should_receive(:save).and_return(false)
        @scene.stub(:errors).and_return(errors)

        post :create, :storybook_id => @storybook.id, :scene => { :storybook_id => @storybook.id }, :format => :json

        response.should_not be_success
        response.body.should eql(errors.to_json)
      end
    end

    context '#update' do
      before(:each) do
        @storybook.should_receive(:scenes).and_return(Scene)
        Scene.should_receive(:find).with(@scene.id.to_s).and_return(@scene)
      end

      it 'should update a scene for the storybook in question' do
        @scene.should_receive(:update_attributes).with('storybook_id' => @storybook.id).and_return(true)
        @scene.stub(:as_json).and_return({ :id => @scene.id })

        put :update, :storybook_id => @storybook.id, :id => @scene.id, :scene => { :storybook_id => @storybook.id }, :format => :json

        response.should be_success
        response.body.should eql({ :id => @scene.id }.to_json)
      end

      it 'should not update a scene if invalid' do
        errors = { :error => 'some error' }
        @scene.should_receive(:update_attributes).with('storybook_id' => @storybook.id).and_return(false)
        @scene.stub(:errors).and_return(errors)

        put :update, :storybook_id => @storybook.id, :id => @scene.id, :scene => { :storybook_id => @storybook.id }, :format => :json

        response.should_not be_success
        response.body.should eql(errors.to_json)
      end
    end

    context '#destroy' do
      before(:each) do
        @storybook.should_receive(:scenes).and_return(Scene)
        Scene.should_receive(:find).with(@scene.id.to_s).and_return(@scene)
      end

      it 'should destroy a scene' do
        @scene.should_receive(:can_be_destroyed?).and_return(true)
        @scene.should_receive(:destroy).and_return(true)

        delete :destroy, :storybook_id => @storybook.id, :id => @scene.id, :format => :json

        response.should be_success
      end

      it 'should not be able to destroy a scene' do
        @scene.should_receive(:can_be_destroyed?).and_return(false)
        @scene.should_not_receive(:destroy)

        delete :destroy, :storybook_id => @storybook.id, :id => @scene.id, :format => :json

        response.should be_success
      end
    end

    context '#sort' do
      it 'should update the position of scenes' do
        Scene.should_receive(:find).with(@scene.id).exactly(2).times.and_return(@scene)
        @scene.should_receive(:position=).with(1).exactly(2).times
        @scene.should_receive(:save).with(:validate => false).exactly(2).times.and_return(true)

        post :sort, :storybook_id => @scene.id, :scenes => [{ :id => @scene.id, :position => 1}, { :id => @scene.id, :position => 1}], :format => :json

        response.should be_success
      end
    end
  end

  context '#images' do
    it 'should return all the images of a scene' do
      @image = mock_model(Image, :id => 1)
      Scene.should_receive(:find).with(@scene.id.to_s).and_return(@scene)
      @scene.should_receive(:storybook).and_return(@storybook)
      @storybook.stub(:owned_by?).with(@user).and_return(true)
      @scene.stub(:images).and_return([@image])
      @image.stub(:as_json).and_return(:id => @image.id)

      get :images, :id => @scene.id, :format => :json

      response.should be_success
      response.body.should eql([{:id => @image.id}].to_json)
    end
  end
end
