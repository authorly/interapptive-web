class Video < Asset
  include Rails.application.routes.url_helpers
  mount_uploader :video, VideoUploader

  def as_jquery_upload_response
    json = {
        'id'                 => id,
        'name'               => read_attribute(:video),
        'size'               => video.size,
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


  # To locally test the videos, after zencoder has done
  # transcoding it, do following in rails console
  #
  # `bundle exec zencoder_fetcher --loop --interval 10 --url 'http://127.0.0.1:3000/zencoder' <ZENCODER_API_KEY>`
  #
  def duration
    ((meta_info[:response].try(:[], 'input').
      try(:[], 'duration_in_ms') || 0) / 1000.0).ceil
  end

  def transcode_complete?
    meta_info[:response].try(:[], 'job').
      try(:[], 'state') == 'finished'
  end

  def store_transcoding_result(response)
    self.meta_info[:response] = response
    save
  end

end
