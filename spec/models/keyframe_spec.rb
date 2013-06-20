require 'spec_helper'

describe Keyframe do
  let!(:keyframe) { Factory(:keyframe) }

  it { keyframe.should be_valid }

  context "#to_json" do
    it 'should be valid response' do
      response = {
          'animation_duration' => keyframe.animation_duration,
          'content_highlight_times' => [],
          'created_at'         => keyframe.created_at,
          'id'                 => keyframe.id,
          'is_animation'       => keyframe.is_animation,
          'position'           => keyframe.position,
          'preview_image_id'   => keyframe.preview_image_id,
          'scene_id'           => keyframe.scene_id,
          'updated_at'         => keyframe.updated_at,
          'voiceover_id'       => nil,
          'widgets'            => keyframe.widgets,
          'preview_image_url'  => keyframe.preview_image.image.url,
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

  describe 'create widgets' do
    it 'should not create orientation widgets for any widgets from the scene' do
      scene = Factory.create(:scene, widgets: [
         {type: 'ButtonWidget'},
         {type: 'HotspotWidget'},
         {type: 'SpriteWidget'}
      ])
      keyframe = Factory.create(:keyframe, scene: scene)

      keyframe.widgets.should_not be
    end

  end

end
