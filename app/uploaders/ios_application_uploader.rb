# encoding: utf-8

class IosApplicationUploader < CarrierWave::Uploader::Base
  #@fog_public = false
  #@fog_authenticated_url_expiration = 3600 # One hour

  # Choose what kind of storage to use for this uploader:
  if Rails.env.development?
    storage :file
  else
    # In test environment, we have mocked fog storage
    storage :fog
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "compiled_applications/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(plist html ipa)
  end

  def index_html_url
    base_url + '/' + 'index.html'
  end

  def manifest_plist_url
    base_url + '/' + 'manifest.plist'
  end

  private

  def base_url
    @base_url ||= File.dirname(@model.compiled_application.url)
  end
end
