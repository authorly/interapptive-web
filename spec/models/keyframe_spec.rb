require 'spec_helper'

describe Keyframe do
  let!(:keyframe) { Factory(:keyframe) }

  it { keyframe.should be_valid }

  context "#to_json" do
    it 'should be valid response' do
      response = {
          'audio'              => {
            'url'              => nil,
            'sphinx_audio'     => { 'url' => nil },
          },
          'content_highlight_times' => [],
          'created_at'         => keyframe.created_at,
          'id'                 => keyframe.id,
          'is_animation'       => keyframe.is_animation,
          'position'           => keyframe.position,
          'preview_image_id'   => keyframe.preview_image_id,
          'scene_id'           => keyframe.scene_id,
          'updated_at'         => keyframe.updated_at,
          'widgets'            => keyframe.widgets,
          'preview_image_url'  => keyframe.preview_image.image.url,
          'url'                => nil
      }.to_json

      keyframe.to_json.should eql(response)
    end
  end

  describe 'animation keyframe validation' do
    it 'should allow an animation keyframe' do
      keyframe = Factory.create(:keyframe)
      Factory.build(:animation_keyframe, scene_id: keyframe.scene_id).should be_valid
    end

    it "should not allow an animation keyframe unless its position is nil" do
      Factory.build(:animation_keyframe, position: 0).should_not be_valid
      Factory.build(:animation_keyframe, position: 1).should_not be_valid
      Factory.build(:animation_keyframe, position: nil).should be_valid
    end

    it 'should not allow two animation keyframes in the same scene' do
      animation = Factory.create(:animation_keyframe)
      Factory.build(:animation_keyframe, scene_id: animation.scene_id).should_not be_valid
    end
  end

  describe 'a keyframe from a scene with sprite widgets' do
    before(:each) do
      @position = {x: 100, y: 200}
      @scale = 3
    end

    it 'should create an orientation widget for each of the sprite widgets from the scene' do
      scene = Factory.create(:scene, widgets: [{id: 1, type: 'SpriteWidget', position: @position, scale: @scale}])
      keyframe = Factory.create(:keyframe, scene: scene)

      keyframe.widgets.count.should == 1
      keyframe.widgets[0][:position].should == @position
      keyframe.widgets[0][:scale].should == @scale
    end

    it 'should create an orientation widget for each of the button widgets from the scene' do
      scene = Factory.create(:scene, widgets: [{type: 'ButtonWidget', position: @position, scale: @scale}])
      keyframe = Factory.create(:keyframe, scene: scene)

      keyframe.widgets.count.should == 1
      keyframe.widgets[0][:position].should == @position
      keyframe.widgets[0][:scale].should == @scale
    end

    it 'should not create orientation widgets for other widgets from the scene' do
      scene = Factory.create(:scene, widgets: [{type: 'HotspotWidget', position: @position, scale: @scale}])
      keyframe = Factory.create(:keyframe, scene: scene)

      keyframe.widgets.count.should == 0
    end
  end

end
