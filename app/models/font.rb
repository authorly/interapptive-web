class Font < Asset
  include Rails.application.routes.url_helpers
  mount_uploader :font, FontUploader

  def as_jquery_upload_response
    {
        'id'               =>   id,
        'name'             =>   meta_info[:font_name],
        'file_name'        =>   font_file_name,
        'size'             =>   font_size,
        'url'              =>   font.url,
        'delete_url'       =>   "/fonts/#{self.id}",
        'delete_type'      =>   'DELETE',
        'asset_type'       =>   asset_type,
        'created_at'       =>   created_at
    }
  end

  def font_file_name
    return meta_info[:font_name] + '.ttf' if asset_type == 'system'
    read_attribute(:font)
  end

  def font_size
    return 42 if asset_type == 'system'
    font.size
  end
end
