class Video < Asset
  include Rails.application.routes.url_helpers
  mount_uploader :video, VideoUploader

  def as_jquery_upload_response
    {
        'id'            =>  id,
        'name'          =>  read_attribute(:video),
        'size'          =>  video.size,
        'duration'      =>  duration,
        'url'           =>  video.url,
        'thumbnail_url' =>  video.thumbnail_url,
        'mp4url'        =>  video.mp4_url,
        'webmurl'       =>  video.webm_url,
        'ogvurl'        =>  video.ogv_url,
        'delete_url'    =>  "/videos/#{self.id}",
        'delete_type'   =>  'DELETE'
    }
  end

  def duration
    ((meta_info.try(:[], :response).
      try(:[], :input).try(:[], :duration_in_ms) || 0) / 1000.0).ceil
  end
end
