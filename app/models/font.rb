class Font < Asset
  include Rails.application.routes.url_helpers
  mount_uploader :font, FontUploader

  def as_jquery_upload_response
    {
        'id' => id,
        'name' => read_attribute(:font),
        'size' => font.size,
        'url' => font.url,
        'delete_url' => "/fonts/#{self.id}",
        'delete_type' => 'DELETE'
    }
  end
end
