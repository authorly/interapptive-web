require 'spec_helper'

describe Scene do
  let!(:scene) { Factory(:scene) }

  it { Factory(:scene).should be_valid }

  context "#to_json" do
    it 'should be valid response' do
      scene.sound_id = Factory.create(:sound).id
      scene.save

      response = {
          'created_at'          => scene.created_at,
          'font_color'          => {r:255,g:0,b:0},
          'font_face'           => 'Arial',
          'font_size'           => '25',
          'id'                  => scene.id,
          'is_main_menu'        => scene.is_main_menu,
          'position'            => scene.position,
          'preview_image_id'    => scene.preview_image.id,
          'sound_id'            => scene.sound_id,
          'sound_repeat_count'  => 0,
          'storybook_id'        => scene.storybook_id,
          'updated_at'          => scene.updated_at,
          'widgets'             => nil,
          'preview_image_url'   => scene.preview_image.image.url,
          'sound_url'           => scene.sound.sound.url
      }.to_json

      scene.to_json.should eql(response)
    end
  end

  context "creation" do
    it 'should create a keyframe in the scene' do
      scene = Scene.create
      scene.keyframes.count.should == 1
      scene.keyframes.first.position.should == 0
      scene.keyframes.first.widgets.should == []
    end

    it 'should add 3 button widgets, and a keyframe, for a main menu scene' do
      scene = Scene.create(is_main_menu: true)
      scene.keyframes.count.should == 1

      scene.widgets.should be
      scene.widgets.count.should == 3
      scene.widgets.all?{|w| w[:type] == 'ButtonWidget'}.should be
      read_it_myself = scene.widgets.detect{|w| w[:name] == 'read_it_myself' }
      read_it_myself.should be
      read_to_me = scene.widgets.detect{|w| w[:name] == 'read_to_me'}
      read_to_me.should be
      auto_play = scene.widgets.detect{|w| w[:name] == 'auto_play' }
      auto_play.should be
      scene.widgets.detect{|w| w[:z_order] == 1}.should be
      scene.widgets.detect{|w| w[:z_order] == 2}.should be
      scene.widgets.detect{|w| w[:z_order] == 3}.should be

      keyframe = scene.keyframes.first
      keyframe.position.should == 0

      keyframe.widgets.should be
      keyframe.widgets.count.should == 3
      keyframe.widgets.all?{|w| w[:type] == 'SpriteOrientation'}.should be

      rimo = keyframe.widgets.detect{|w| w[:sprite_widget_id] == read_it_myself[:id] }
      rimo.should be
      rimo[:position].should == {y: 100, x: 200}
      rimo[:scale].should == 1

      rtm = keyframe.widgets.detect{|w| w[:sprite_widget_id] == read_to_me[:id] }
      rtm.should be
      rtm[:position].should == {y: 200, x: 200}
      rtm[:scale].should == 1

      ap = keyframe.widgets.detect{|w| w[:sprite_widget_id] == auto_play[:id] }
      ap.should be
      ap[:position].should == {y: 300, x: 200}
      ap[:scale].should == 1
    end

  end

  describe 'validation for is_main_menu' do
    it 'should allow one main menu scene' do
      scene = Factory.create(:scene)
      Factory.build(:main_menu_scene, storybook_id: scene.storybook_id).should be_valid
    end

    it "should not allow a main menu scene unless its position is nil" do
      Factory.build(:main_menu_scene, position: 0).should_not be_valid
      Factory.build(:main_menu_scene, position: 1).should_not be_valid
      Factory.build(:main_menu_scene, position: nil).should be_valid
    end

    it 'should not allow two main menu scenes in the same story' do
      main_menu = Factory.create(:main_menu_scene)
      Factory.build(:main_menu_scene, storybook_id: main_menu.storybook_id).should_not be_valid
     end
  end

end
