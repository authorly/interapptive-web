# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

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
    "images/#{model.id}"
  end

  # Devices upto i4 crash if they are given images of
  # height or width of greater than 2048. See #681
  version :cocos2d do
    process :resize_to_limit => [2048, 2048]
  end

  # Create different versions of your uploaded files:
  version :mini do
    process :resize_to_fit => [50, 50]
  end

  version :thumb do
    process :resize_to_fit => [100, 100]
  end

  version :small do
    process :resize_to_fit => [175, 175]
  end

  version :keyframe_thumb do
    process :resize_to_fit => [115, 65]
  end

  version :scene_thumb do
    process :resize_to_fit => [160, 125]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w( jpg jpeg gif png )
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
