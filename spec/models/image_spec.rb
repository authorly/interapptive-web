require 'spec_helper'

describe Image do
  let!(:image) { Factory(:image) }

  context "#as_jquery_upload_response" do
    it 'should be valid response' do
      # Following chokes with image returned from Factory(:image)
      im = Image.new
      im.image = File.open(Rails.root.join("spec/factories/images/350x350.png"))
      im.save!

      response = {
        'id'            => im.id,
        'name'          => im.read_attribute(:image),
        'size'          => im.image.size,
        'url'           => im.image.url,
        'thumbnail_url' => im.image.thumb.url,
        'delete_url'    => "/images/#{im.id}",
        'delete_type'   => 'DELETE',
        'created_at'    => im.created_at
      }

      im.as_jquery_upload_response.should eql(response)
    end
  end
end
