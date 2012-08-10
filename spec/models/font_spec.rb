require 'spec_helper'

describe Image do
  let!(:font) { Factory(:font) }

  context "#as_jquery_upload_response" do
    it 'should be valid response' do
      # Following chokes with image returned from Factory(:image)
      f = Font.new
      f.font = File.open(Rails.root.join("spec/factories/fonts/font.ttf"))
      f.save!

      response = {
        'id'          => f.id,
        'name'        => f.read_attribute(:font),
        'size'        => f.font.size,
        'url'         => f.font.url,
        'delete_url'  => "/fonts/#{f.id}",
        'delete_type' => 'DELETE'
      }

      f.as_jquery_upload_response.should eql(response)
    end
  end
end
