# encoding: utf-8

class AppIconUploader < CarrierWave::Uploader::Base

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
    "app_icons/#{model.id}"
  end

  # Create different versions of your uploaded files:
  version :app_icon do
    version :app_icon_20_20 do
      process :resize_to_fill => [20, 20]
    end

    version :app_icon_29_29 do
      process :resize_to_fill => [29, 29]
    end

    version :app_icon_30_30 do
      process :resize_to_fill => [30, 30]
    end

    version :app_icon_32_32 do
      process :resize_to_fill => [32, 32]
    end

    version :app_icon_40_40 do
      process :resize_to_fill => [40, 40]
    end

    version :app_icon_48_48 do
      process :resize_to_fill => [48, 48]
    end

    version :app_icon_50_50 do
      process :resize_to_fill => [50, 50]
    end

    version :app_icon_57_57 do
      process :resize_to_fill => [57, 57]
    end

    version :app_icon_58_58 do
      process :resize_to_fill => [58, 58]
    end

    version :app_icon_60_60 do
      process :resize_to_fill => [60, 60]
    end

    version :app_icon_72_72 do
      process :resize_to_fill => [72, 72]
    end

    version :app_icon_76_76 do
      process :resize_to_fill => [76, 76]
    end

    version :app_icon_80_80 do
      process :resize_to_fill => [80, 80]
    end

    version :app_icon_96_96 do
      process :resize_to_fill => [96, 96]
    end

    version :app_icon_100_100 do
      process :resize_to_fill => [100, 100]
    end

    version :app_icon_114_114 do
      process :resize_to_fill => [114, 114]
    end

    version :app_icon_120_120 do
      process :resize_to_fill => [120, 120]
    end

    version :app_icon_144_144 do
      process :resize_to_fill => [144, 144]
    end

    version :app_icon_152_152 do
      process :resize_to_fill => [152, 152]
    end

    version :app_icon_app_store_512_512 do
      process :resize_to_fill => [512, 512]
    end

    version :app_icon_app_store_1024_1024 do
      process :resize_to_fill => [1024, 1024]
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg JPG jpeg JPEG gif GIF png PNG)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
