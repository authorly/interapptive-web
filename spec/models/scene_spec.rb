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
          'font_color'          => 'rgb(0, 0, 0)',
          'font_face'           => 'Arial',
          'font_size'           => '25',
          'id'                  => scene.id,
          'is_main_menu'        => scene.is_main_menu,
          'position'            => scene.position,
          'preview_image_id'    => scene.preview_image_id,
          'sound_id'            => scene.sound_id,
          'sound_repeat_count'  => 0,
          'storybook_id'        => scene.storybook_id,
          'updated_at'          => scene.updated_at,
          'widgets'             => nil,
          'preview_image_url'   => nil,
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
      scene.keyframes.first.widgets.should_not be
    end

    it 'should create a keyframe with 3 static widgets, in a main menu scene' do
      scene = Scene.create(is_main_menu: true)
      scene.keyframes.count.should == 1

      keyframe = scene.keyframes.first
      keyframe.position.should == 0

      scene.widgets.should be
      scene.widgets.count.should == 3
      scene.widgets.all?{|w| w[:type] == 'ButtonWidget'}.should be
      scene.widgets.detect{|w| w[:name] == 'read_it_myself' }.should be
      scene.widgets.detect{|w| w[:name] == 'auto_play' }.should be
      scene.widgets.detect{|w| w[:name] == 'read_to_me'}.should be
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
