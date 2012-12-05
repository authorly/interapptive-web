# encoding: utf-8
require 'interapptive/carrier_wave/sphinx_audio_converter'
class KeyframeAudioUploader < CarrierWave::Uploader::Base
  include Interapptive::CarrierWave::SphinxAudioConverter

  # Choose what kind of storage to use for this uploader:
  if Rails.env.development?
    storage :fog
  else
    # In test environment, we have mocked fog storage
    storage :fog
  end

  version :sphinx_audio do
    process :convert_audio => []

    def full_filename(for_file)
      "sphinx_audio_#{File.basename(for_file, '.*')}.wav"
    end
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "keyframe_audios/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(wav)
  end
end
