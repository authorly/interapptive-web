class Sound < Asset
  include Rails.application.routes.url_helpers
  include Interapptive::ZencodedAsset
  mount_uploader :sound, SoundUploader

  def as_jquery_upload_response
    json = {
      'id'                 => id,
      'name'               => read_attribute(:sound),
      'size'               => max_size,
      'url'                => sound.url,
      'delete_url'         => "/sounds/#{self.id}",
      'delete_type'        => 'DELETE',
      'created_at'         => created_at,
      'transcode_complete' => transcode_complete?,
      'type'               => type
    }
    if transcode_complete?
      json.merge!({
        'mp3url'             => sound.mp3_url,
        'oggurl'             => sound.ogg_url,
        'duration'           => duration
      })
    end
    json
  end

  def self.valid_extension?(ext)
    SoundUploader.new.extension_white_list.include? ext
  end

end
