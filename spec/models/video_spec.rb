require 'spec_helper'

describe Video do
  before(:each) do
    zencoder_response = Object.new
    def zencoder_response.body; { :zencoder => 'response' }; end
    Zencoder::Job.stub(:create).and_return(zencoder_response)
    @video = Video.new
    @video.video = File.open(Rails.root.join("spec/factories/videos/null_video.flv"))
    @video.save!
  end

  context "#as_jquery_upload_response" do
    it 'should be valid response' do
      response = {
        'id'                 => @video.id,
        'name'               => @video.read_attribute(:video),
        'size'               => @video.video.size,
        'url'                => @video.video.url,
        'delete_url'         => "/videos/#{@video.id}",
        'delete_type'        => 'DELETE',
        "mp4url"             => @video.video.mp4_url,
        "webmurl"            => @video.video.webm_url,
        "ogvurl"             => @video.video.ogv_url,
        "thumbnail_url"      => @video.video.thumbnail_url,
        'duration'           => 0,
        'created_at'         => @video.created_at,
        'transcode_complete' => @video.transcode_complete?
      }

      @video.as_jquery_upload_response.should eql(response)
    end
  end

  context "#duration" do
    it 'should return zero by default' do
      @video.duration.should eql(0)
    end

    it 'should return duration' do
      @video.meta_info[:response] = { :input => { :duration_in_ms => 1000 } }
      @video.duration.should eql(1)
    end

    it 'should return zero if no duration key' do
      @video.meta_info[:response] = { :input => { }}
      @video.duration.should eql(0)
    end
  end
end
