# encoding: utf-8
require 'authorly/carrier_wave/video_thumbnailer'

class VideoUploader < CarrierWave::Uploader::Base
  include Authorly::CarrierWave::VideoThumbnailer
  include CarrierWave::Video

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  if Rails.env.development?
    storage :fog
  else
    # In test environment, we have mocked fog storage
    storage :fog
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "videos/#{model.id}"
  end

  # OPTIMIZE: WA: Currently the transcoding process is tied with video uploading.
  # Offload this to a background process. See https://gist.github.com/1541912 and
  # https://groups.google.com/forum/?fromgroups=#!topic/carrierwave/afnopCrcGfM
  version :mp4 do
    process :encode_video => [:mp4, :resolution => :same, :audio_codec => 'aac', :custom => '-q:v 0 -q:a 0 -vpre slow -vpre baseline -g 30 -strict -2']
    def full_filename(for_file)
      "mp4_#{File.basename(for_file, '.*')}.mp4"
    end
  end

  version :webm do
    process :encode_video => [:webm, :resolution => :same]
    def full_filename(for_file)
      "webm_#{File.basename(for_file, '.*')}.webm"
    end
  end

  version :ogv do
    process :encode_video => [:ogv, :resolution => :same]
    def full_filename(for_file)
      "ogv_#{File.basename(for_file, '.*')}.ogv"
    end
  end

  version :thumbnail do
    process :video_thumbnail => [{ :seek_time => 4, :resolution => '100x100' }, { :preserve_aspect_ratio => :width }]
    def full_filename(for_file)
      # TODO: WA: It is assumed that thumbnail of the video is present in png
      # format. Make it dynamic by passing a parameter to VideoThumbnailer
      # and use that value here instead.
      "thumbnail_#{File.basename(for_file, '.*')}.png"
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w( avi mov mkv mpg mpeg mp4 m4v flv)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
