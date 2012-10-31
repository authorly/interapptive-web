class Video < Asset
  include Rails.application.routes.url_helpers
  mount_uploader :video, VideoUploader

  def as_jquery_upload_response
    {
        'id' => id,
        'name' => read_attribute(:video),
        'size' => video.size,
        'url' => video.url,
        'thumbnail_url' => video.thumbnail.url,
        'delete_url' => "/videos/#{self.id}",
        'delete_type' => 'DELETE'
    }
  end
end
