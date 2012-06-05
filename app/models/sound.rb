class Sound < Asset
  include Rails.application.routes.url_helpers
  mount_uploader :sound, SoundUploader

  def as_jquery_upload_response
    {
        'id' => id,
        'name' => read_attribute(:sound),
        'size' => sound.size,
        'url' => sound.url,
        'delete_url' => "/sounds/#{self.id}",
        'delete_type' => 'DELETE'
    }
  end
end
