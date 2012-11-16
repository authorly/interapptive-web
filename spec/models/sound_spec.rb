require 'spec_helper'

describe Sound do
  let!(:sound) { Factory(:sound) }

  context "#as_jquery_upload_response" do
    it 'should be valid response' do
      # Following chokes with image returned from Factory(:sound)
      s = Sound.new
      s.sound = File.open(Rails.root.join("spec/factories/sounds/voicemail_received.wav"))
      s.save!

      response = {
        'id'          => s.id,
        'name'        => s.read_attribute(:sound),
        'size'        => s.sound.size,
        'url'         => s.sound.url,
        'delete_url'  => "/sounds/#{s.id}",
        'delete_type' => 'DELETE',
        'created_at'  => s.created_at
      }

      s.as_jquery_upload_response.should eql(response)
    end
  end
end
