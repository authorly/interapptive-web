require 'spec_helper'

describe Scene do
  let!(:scene) { Factory(:scene) }

  it { Factory(:scene).should be_valid }

  context "#to_json" do
    it 'should be valid response' do
      response = {
          'created_at'       => scene.created_at,
          'id'               => scene.id,
          'image_id'         => scene.image_id,
          'page_number'      => scene.page_number,
          'preview_image_id' => scene.preview_image_id,
          'sound_id'         => scene.sound_id,
          'storybook_id'     => scene.storybook_id,
          'updated_at'       => scene.updated_at
      }.to_json

      scene.to_json.should eql(response)
    end
  end
end