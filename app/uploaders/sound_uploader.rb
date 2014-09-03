# encoding: utf-8

require 'interapptive/carrier_wave/wav_video_converter'

class SoundUploader < CarrierWave::Uploader::Base
  include Interapptive::CarrierWave::WavVideoConverter
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
  # In test environment, we have mocked fog storage
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # Change App.Models.Storybook#_parseAssetUrl() if following is changed
    "sounds/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  # process :store_duration => []

  # Create different versions of your uploaded files:
   version :aligner_wav do
     process :encode_to_wav => []
     def full_filename(for_file)
       "#{File.basename(for_file, File.extname(for_file))}.wav"
     end
   end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(aac AAC mp3 MP3 m4a M4A wav WAV ogg OGG)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def mp3_url
    @mp3_url ||= url_for_format('mp3')
  end

  def ogg_url
    @ogg_url ||= url_for_format('ogg')
  end

  private

  def zencode(*args)
    notification_url = Rails.env.development? ?
      'http://zencoderfetcher/':
      zencoder_url
    params = {
      :input         => @model.sound.url,
      :test          => ['test'].include?(Rails.env), # Zencoder Integration mode. https://app.zencoder.com/docs/guides/getting-started/test-jobs-and-integration-mode
      :notifications => [notification_url],
      :pass_through  => 'Sound_' + @model.id.to_s,
      :outputs => [
        {
          :public      => true,
          :base_url    => base_url,
          :filename    => name_for_format('mp3'),
          :label       => 'webmp3',
          :format      => 'mp3',
          :audio_codec => 'mp3',
        },
        {
          :public      => true,
          :base_url    => base_url,
          :filename    => name_for_format('ogg'),
          :label       => 'webogg',
          :format      => 'ogg',
          :audio_codec => 'vorbis',
        }
      ]
    }

    z_response = Zencoder::Job.create(params)
    @model.meta_info[:request] = z_response.body
    @model.save(:validate => false)
  end

  def filename_without_ext
    @filename_without_ext ||= File.basename(@model.sound.url, File.extname(@model.sound.url))
  end

  def base_url
    @base_url ||= File.dirname(@model.sound.url)
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
