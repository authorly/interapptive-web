require 'spec_helper'

describe Font do
  let!(:font) { Factory(:font) }

  context "#as_jquery_upload_response" do
    it 'should be valid response' do
      # Following chokes with image returned from Factory(:image)
      f = Font.new
      f.font = File.open(Rails.root.join("spec/factories/fonts/font.ttf"))
      f.save!

      response = {
        'id'          => f.id,
        'name'        => f.meta_info[:font_name],
        'size'        => f.font.size,
        'url'         => f.font.url,
        'created_at'  => f.created_at.strftime("%Y %d %_m %l%p"),
        'delete_url'  => "/fonts/#{f.id}",
        'delete_type' => 'DELETE',
        'created_at'  => f.created_at
      }

      f.as_jquery_upload_response.should eql(response)
    end
  end
end
