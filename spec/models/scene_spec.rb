require 'spec_helper'

describe Scene do

  it { Factory.build(:scene).should be_valid }

  context "#to_json" do
    it 'should be valid response' do
      scene = Factory(:scene, sound: Factory.create(:sound))

      response = {
          'created_at'          => scene.created_at,
          'id'                  => scene.id,
          'is_main_menu'        => scene.is_main_menu,
          'loop_sound'          => false,
          'position'            => scene.position,
          'sound_id'            => scene.sound_id,
          'storybook_id'        => scene.storybook_id,
          'updated_at'          => scene.updated_at,
          'widgets'             => nil,
          'sound_id'           => scene.sound.id
      }.to_json

      scene.to_json.should eql(response)
    end
  end

  context "creation" do

    context 'a normal scene' do

      it 'should a keyframe in the scene' do
        scene = Scene.create!(storybook: Factory(:storybook))
        scene.keyframes.count.should == 1
        scene.keyframes[0].is_animation.should == false
        scene.keyframes[0].position.should == 0
      end

    end

    context 'the main menu' do

      it 'should add a keyframe' do
        scene = Factory.create(:main_menu_scene)
        scene.keyframes.count.should == 1
        scene.keyframes[0].is_animation.should == false
      end

      it 'should add 3 button widgets' do
        scene = Factory.create(:main_menu_scene)

        scene.widgets.should be
        scene.widgets.count.should == 3
        scene.widgets.all?{|w| w[:type] == 'ButtonWidget'}.should be
        read_it_myself = scene.widgets.detect{|w| w[:name] == 'read_it_myself' }
        read_it_myself.should be
        read_it_myself[:z_order].should == 4001
        read_it_myself[:position].should == {y: 200, x: 512}
        read_it_myself[:scale].should == 1

        read_to_me = scene.widgets.detect{|w| w[:name] == 'read_to_me'}
        read_to_me.should be
        read_to_me[:z_order].should == 4002
        read_to_me[:position].should == {y: 200, x: 177}
        read_to_me[:scale].should == 1

        auto_play = scene.widgets.detect{|w| w[:name] == 'auto_play' }
        auto_play.should be
        auto_play[:z_order].should == 4003
        auto_play[:position].should == {y: 200, x: 844}
        auto_play[:scale].should == 1
      end

    end

  end

  describe 'validation for is_main_menu' do
    before(:each) do
      @storybook = Factory(:storybook)
      @storybook.scenes.destroy_all
    end

    it 'should allow one main menu scene' do
      scene = Factory(:scene, storybook: @storybook)
      Factory.build(:main_menu_scene, storybook: @storybook).should be_valid
    end

    it "should not allow a main menu scene with position 0" do
      Factory.build(:main_menu_scene, storybook: @storybook, position: 0).should_not be_valid
    end

    it "should not allow a main menu scene with position 1" do
      Factory.build(:main_menu_scene, storybook: @storybook, position: 1).should_not be_valid
    end

    it "should allow a main menu scene with position nil" do
      Factory.build(:main_menu_scene, storybook: @storybook, position: nil).should be_valid
    end

    it 'should not allow two main menu scenes in the same story' do
      main_menu = Factory.create(:main_menu_scene, storybook: @storybook)
      Factory.build(:main_menu_scene, storybook: @storybook).should_not be_valid
    end
  end

  describe 'destroy' do
    it 'is allowed for regular scenes' do
      Factory.build(:scene).can_be_destroyed?.should == true
    end

    it 'is not allowed for main menu scenes' do
      Factory.build(:main_menu_scene).can_be_destroyed?.should == false
    end
  end

end
