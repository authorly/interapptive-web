class Video < Asset
  include Rails.application.routes.url_helpers
  include Interapptive::ZencodedAsset
  mount_uploader :video, VideoUploader

  def as_jquery_upload_response
    json = {
        'id'                 => id,
        'name'               => read_attribute(:video),
        'size'               => max_size,
        'url'                => video.url,
        'delete_url'         => "/videos/#{self.id}",
        'delete_type'        => 'DELETE',
        'created_at'         => created_at,
        'transcode_complete' => transcode_complete?,
        'type'               => type
    }
    if transcode_complete?
      json.merge!({
        'thumbnail_url'      => video.thumbnail_url,
        'mp4url'             => video.mp4_url,
        'webmurl'            => video.webm_url,
        'ogvurl'             => video.ogv_url,
        'duration'           => duration
      })
    end
    json
  end

  def self.valid_extension?(ext)
    VideoUploader.new.extension_white_list.include? ext
  end

end
