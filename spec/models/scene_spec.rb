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
          'id'                  => scene.id,
          'position'            => scene.position,
          'preview_image_id'    => scene.preview_image_id,
          'sound_id'            => scene.sound_id,
          'sound_repeat_count'  => 0,
          'storybook_id'        => scene.storybook_id,
          'updated_at'          => scene.updated_at,
          'preview_image_url'   => nil,
          'sound_url'           => scene.sound.sound.url
      }.to_json

      scene.to_json.should eql(response)
    end
  end

  context "creation" do
    it 'should create corresponding scene' do
      scene = Scene.create
      scene.keyframes.should be_any
    end
  end
end
