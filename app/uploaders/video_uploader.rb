# encoding: utf-8
class VideoUploader < CarrierWave::Uploader::Base
  include Rails.application.routes.url_helpers
  Rails.application.routes.default_url_options = ActionMailer::Base.default_url_options

  after :store, :zencode

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

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(avi AVI mov MOV mkv MKV mpg MPG mpeg MPEG mp4 MP4 m4v M4V flv FLV)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def thumbnail_url
    @thubnail_url ||= url_for_format('thumbnail', 'png')
  end

  def mp4_url
    @mp4_url ||= url_for_format('mp4')
  end

  def webm_url
    @webm_url ||= url_for_format('webm')
  end

  def ogv_url
    @ogv_url ||= url_for_format('ogv')
  end

  private

  def zencode(*args)
    notification_url = Rails.env.development? ?
      'http://zencoderfetcher/':
      zencoder_url
    params = {
      :input         => @model.video.url,
      :test          => true, # Enable Integration mode by default for all videos for now. https://app.zencoder.com/docs/guides/getting-started/test-jobs-and-integration-mode
      :notifications => [notification_url],
      :pass_through  => @model.id,
      :outputs => [
        {
          :public      => true,
          :base_url    => base_url,
          :filename    => name_for_format('mp4'),
          :label       => 'webmp4',
          :format      => 'mp4',
          :audio_codec => 'aac',
          :video_codec => 'h264'
        },
        {
          :public      => true,
          :base_url    => base_url,
          :filename    => name_for_format('webm'),
          :label       => 'webwebm',
          :format      => 'webm',
          :audio_codec => 'vorbis',
          :video_codec => 'vp8'
        },
        {
          :public      => true,
          :base_url    => base_url,
          :filename    => name_for_format('ogv'),
          :label       => 'webogv',
          :format      => 'ogv',
          :audio_codec => 'vorbis',
          :video_codec => 'theora'
        },
        {
         :thumbnails => {
           :public      => true,
           :base_url    => base_url,
           :filename    => name_for_format('thumbnail', nil, false),
           :times       => [4],
           :aspect_mode => 'preserve',
           :width       => '100',
           :height      => '100'
         }
       }
     ]
    }

    z_response = Zencoder::Job.create(params)
    @model.meta_info[:request] = z_response.body
    @model.save(:validate => false)
  end

  def filename_without_ext
    @filename_without_ext ||= File.basename(@model.video.url, File.extname(@model.video.url))
  end

  def base_url
    @base_url ||= File.dirname(@model.video.url)
  end

  def url_for_format(format, extension=nil)
    base_url + '/' + name_for_format(format, extension)
  end

  def name_for_format(format, extension=nil, with_extension=true)
    name = format + '_' + filename_without_ext
    name += ".#{extension || format}" if with_extension
    name
  end
end
