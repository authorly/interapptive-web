module Interapptive
  module CarrierWave
    module SphinxAudioConverter
      extend ActiveSupport::Concern

      module ClassMethods
        def convert_audio(*args)
          process :convert_audio => args
        end
      end

      # Expects Sox version 14.4.0
      def convert_audio(*args)
        directory = File.dirname(current_path)

        sphinx_audio_path = directory + '/' + SecureRandom.hex + '.wav'
        f = IO.popen("sox #{current_path} -r 16000 -c 1 -e signed-integer #{sphinx_audio_path}")
        f.close
        FileUtils.rm(current_path)
        FileUtils.mv(sphinx_audio_path, current_path)
      end
    end
  end
end
