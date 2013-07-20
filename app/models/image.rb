class Image < Asset
  mount_uploader :image, ImageUploader

  def data_encoded_image
    nil
  end


  def data_encoded_image=(encoded)
    self.image = self.class.data_encoded_to_binary(encoded)
  end

  def as_jquery_upload_response
    {
      'id'            =>    id,
      'name'          =>    read_attribute(:image),
      'size'          =>    image.size,
      'url'           =>    image.cocos2d.url,
      'thumbnail_url' =>    image.thumb.url,
      'delete_url'    =>    "/images/#{self.id}",
      'delete_type'   =>    'DELETE',
      'created_at'    =>    created_at
    }
  end

  private

  def self.data_encoded_to_binary(encoded)
    encoded.gsub!(/[^,]+,/, '')
    file = Tempfile.new(['image', '.png'])
    file.binmode
    file.write(Base64.decode64(encoded))
    file
  end
end
