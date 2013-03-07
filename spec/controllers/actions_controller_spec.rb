require 'spec_helper'

describe ActionsController do
  before(:each) do
    @user = User.new(:id => 1)
    test_sign_in(@user)
  end

  context '#definitions' do
    it 'should give all the action definitions with attribute definitions' do
      # See the rationale behind this spec at https://github.com/rspec/rspec-mocks/issues/78
      @action_definition = ActionDefinition.new(:description => 'some description', :name => "CCSomeAction", :enabled => true)
      @attribute_definition = AttributeDefinition.new(:type => 'some_type', :name => 'attribute_name')
      @action_definition.id, @attribute_definition.id = [1, 1]
      ActionDefinition.should_receive(:includes).with(:attribute_definitions).and_return([@action_definition])
      @action_definition.stub(:attribute_definitions).and_return([@attribute_definition])

      get :definitions, :format => :json

      response.should be_success
      response.body.should eql([@action_definition].to_json(:include => :attribute_definitions))
    end

    context '#update' do
      before(:each) do
        @action = Action.new
        @action.id = 1
        Action.stub(:find).and_return(@action)
      end

      it 'should update the action' do
        @action.should_receive(:update_attributes).with('value' => 'some value').and_return(true)

        put :update, :id => @action.id, :aktion => { :value => 'some value' }, :format => :json

        response.should be_success
      end

      it 'should not update the action when invalid' do
        @action.should_receive(:update_attributes).with('value' => 'some value').and_return(false)
        errors = { :error => 'some error' }
        @action.stub(:errors).and_return(errors)

        put :update, :id => @action.id, :aktion => { :value => 'some value' }, :format => :json

        response.should_not be_success
        response.body.should eql(errors.to_json)
      end
    end
  end

  describe 'Scene Authorized actions' do
    before(:each) do
      @storybook = Storybook.new(:title => "Some storybook")
      @scene = Scene.new
      @action = Action.new
      @storybook.id, @scene.id, @action.id = [1, 1, 1]

      Scene.stub(:find).with(@scene.id).and_return(@scene)
      @scene.stub(:storybook).and_return(@storybook)
      @storybook.stub(:owned_by?).with(@user).and_return(true)
    end

    context '#index' do
      it 'should give actions of the scene in question' do
        @scene.should_receive(:actions).and_return([@action])

        get :index, :scene_id => @scene.id, :format => :json

        response.should be_success
        response.body.should eql([@action.as_json].to_json)
      end
    end

    context '#show' do
      it 'should render a specific action' do
        @scene.stub(:actions).and_return(Action)
        Action.stub(:find).with(@action.id.to_s).and_return(@action)

        get :show, :scene_id => @scene.id, :id => @action.id, :format => :json

        response.should be_success
        response.body.should eql(@action.to_json)
      end
    end

    context "#create" do
      before(:each) do
        @action_definition = ActionDefinition.new(:description => 'some description', :name => "CCSomeAction", :enabled => true)
        @attribute_definition = AttributeDefinition.new(:type => 'some_type', :name => 'attribute_name')
        @action_definition.id, @attribute_definition.id = [1, 1]

        ActionDefinition.stub(:find).with(@action_definition.id).and_return(@action_definition)
        @scene.stub(:actions).and_return(Action)
        Action.stub(:create).with(:action_definition => @action_definition).and_return(@action)
        @action_definition.stub(:attribute_definitions).and_return([@attribute_definition, @attribute_definition])
        @action.stub(:action_attributes).and_return(Attribute)
        Attribute.should_receive(:create).with(:attribute_definition => @attribute_definition, :value => 'some value')
        .exactly(2).times.and_return(true)
      end

      it 'should create an action with action definition and attributes for valid attributes' do
        @action.stub(:as_json).and_return({ :id => @action.id })
        @action.should_receive(:save).and_return(true)

        post :create, :scene_id => @scene.id, :action_definition => { :id => @action_definition.id },
          :action_attributes => { @attribute_definition.name => { :value => 'some value' } }, :format => :json

        response.code.should eql('201')
        response.body.should eql(@action.to_json)
      end

      it 'should not create an action with action definition and attributes for invalid attributes' do
        errors = { :error => 'some error' }
        @action.should_receive(:save).and_return(false)
        @action.stub(:errors).and_return(errors)

        post :create, :scene_id => @scene.id, :action_definition => { :id => @action_definition.id },
          :action_attributes => { @attribute_definition.name => { :value => 'some value' } }, :format => :json

        response.code.should eql('200')
        response.body.should eql(errors.to_json)
      end
    end

    context '#destroy' do
      it 'should destroy an action' do
        @scene.stub(:actions).and_return(Action)
        Action.stub(:find).with(@action.id.to_s).and_return(@action)
        @action.should_receive(:destroy).and_return(true)

        delete :destroy, :id => @action.id, :scene_id => @scene.id, :format => :json

        response.should be_success
      end
    end
  end
end
