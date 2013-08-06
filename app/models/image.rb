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
      'created_at'    =>    created_at,
      'type'          =>    type
    }
  end

  def image_size
    begin
      image.size
    rescue => e
      logger.info "Size of image not accessible for image: #{id}\n"
      logger.info e.message
      0
    end
  end

  def self.valid_extension?(ext)
    ImageUploader.new.extension_white_list.include? ext
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
