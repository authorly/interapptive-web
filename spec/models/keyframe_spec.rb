require 'spec_helper'

describe Keyframe do
  let!(:keyframe) { Factory(:keyframe) }

  it { Factory(:keyframe).should be_valid }

  context "#to_json" do
    it 'should be valid response' do
      response = {
          'background_x_coord' => keyframe.background_x_coord,
          'background_y_coord' => keyframe.background_y_coord,
          'created_at'         => keyframe.created_at,
          'id'                 => keyframe.id,
          'image_id'           => keyframe.image_id,
          'position'           => keyframe.position,
          'scene_id'           => keyframe.scene_id,
          'updated_at'         => keyframe.updated_at,
          'widgets'            => keyframe.widgets
      }.to_json

      keyframe.to_json.should eql(response)
    end
  end
end
