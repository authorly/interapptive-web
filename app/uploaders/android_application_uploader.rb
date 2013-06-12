# encoding: utf-8

class AndroidApplicationUploader < CarrierWave::Uploader::Base
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
    "android_applications/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(apk)
  end
end
