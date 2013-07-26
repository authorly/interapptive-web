require 'spec_helper'

describe Image do

  context "#as_jquery_upload_response" do
    let!(:image) { Factory(:image) }

    it 'should be valid response' do
      # Following chokes with image returned from Factory(:image)
      im = Image.new
      im.image = File.open(Rails.root.join("spec/factories/images/350x350.png"))
      im.save!

      response = {
        'id'            => im.id,
        'name'          => im.read_attribute(:image),
        'size'          => im.image.size,
        'url'           => im.image.cocos2d.url,
        'thumbnail_url' => im.image.thumb.url,
        'delete_url'    => "/images/#{im.id}",
        'delete_type'   => 'DELETE',
        'created_at'    => im.created_at,
        'type'          => 'Image',
      }

      im.as_jquery_upload_response.should eql(response)
    end
  end

  describe 'when created from a data url' do
    let(:red_dot) { "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA
AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO
9TXL0Y4OHwAAAABJRU5ErkJggg==" }
    subject { Factory(:image, image: nil, data_encoded_image: red_dot ) }

    its(:image) { should be }
  end
end
