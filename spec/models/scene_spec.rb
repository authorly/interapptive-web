require 'spec_helper'

describe Scene do
  let!(:scene) { Factory(:scene) }

  it { Factory(:scene).should be_valid }

  it { should have_many(:keyframes) }
  it { should have_many(:asset_maps) }
  it { should have_many(:touch_zones) }
  it { should have_many(:images).through(:asset_maps) }
  it { should have_many(:sounds).through(:asset_maps) }
  it { should have_many(:videos).through(:touch_zones) }

  it { should have_one(:scene_settings) }
  it { should have_one(:font).through(:scene_settings) }

  context "#to_json" do
    it "includes the ID" do
      scene.to_json.should have_json_path("id")
      scene.to_json.should have_json_type(Integer).at_path("id")
    end

    it "includes the storybook ID" do
      scene.to_json.should have_json_path("storybook_id")
      scene.to_json.should have_json_type(Integer).at_path("storybook_id")
    end

    it "includes an optional sound ID" do
      scene.to_json.should have_json_path("sound_id")
      scene.to_json.should have_json_type(Integer).at_path("sound_id")
    end

    it "includes an optional background image ID" do
      scene.to_json.should have_json_path("image_id")
      scene.to_json.should have_json_type(Integer).at_path("image_id")
    end
  end
end