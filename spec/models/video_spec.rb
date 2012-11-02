require 'spec_helper'

describe Video do
  let!(:video) { Factory(:video) }

  context "#as_jquery_upload_response" do
    it 'should be valid response' do
      # Following chokes with image returned from Factory(:sound)
      v = Video.new
      v.video = File.open(Rails.root.join("spec/factories/videos/null_video.flv"))
      v.save!

      response = {
        'id'          => v.id,
        'name'        => v.read_attribute(:video),
        'size'        => v.video.size,
        'url'         => v.video.url,
        'delete_url'  => "/videos/#{v.id}",
        'delete_type' => 'DELETE',
        "mp4url"      => v.video.mp4.url,
        "webmurl"     => v.video.webm.url,
        "ogvurl"      => v.video.ogv.url,
        "thumbnail_url"      => v.video.thumbnail.url,
      }

      v.as_jquery_upload_response.should eql(response)
    end
  end
end
