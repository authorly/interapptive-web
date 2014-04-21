require 'spec_helper'

describe Sound do
  let(:sound) { Factory(:sound, sound: File.open(Rails.root.join("spec/factories/sounds/voicemail_received.wav"))) }

  before(:each) do
    Zencoder::Job.stub_chain(:create, :body).and_return('')
  end

  context "#as_jquery_upload_response" do
    let(:json) {
      {
        'id'                 => sound.id,
        'name'               => sound.read_attribute(:sound),
        'size'               => 0,
        'url'                => sound.sound.url,
        'delete_url'         => "/sounds/#{sound.id}",
        'delete_type'        => 'DELETE',
        'created_at'         => sound.created_at,
        'type'               => 'Sound',
        'transcode_complete' => false,
      }
    }

    it 'should be valid response' do
      sound.as_jquery_upload_response.should eql(json)
    end

    it 'should contain more details after transcoding' do
      sound.meta_info[:response] = {'job' => {'state' => 'finished' }, 'input' => {'duration_in_ms' => 23000},
        'outputs' => [{'file_size_in_bytes' => 1234}, {'file_size_in_bytes' => 7892}]}
      expected = json.merge({
        'mp3url'             => "http://authorly-test.s3.amazonaws.com/sounds/#{sound.id}/mp3_voicemail_received.mp3",
        'oggurl'             => "http://authorly-test.s3.amazonaws.com/sounds/#{sound.id}/ogg_voicemail_received.ogg",
        'duration'           => 23,
        'transcode_complete' => true,
        'size'               => 7892, # max from transcoded ones
      })
      sound.as_jquery_upload_response.should eql(expected)
    end
  end
end
