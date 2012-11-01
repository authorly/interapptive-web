module Authorly
  module CarrierWave
    module VideoThumbnailer
      extend ActiveSupport::Concern

      module ClassMethods
        def video_thumbnail(options = {}, other_options = {})
          process :video_thumbnail => [options, other_options]
        end
      end

      def video_thumbnail(options = {}, other_options = {})
        p current_path
        directory = File.dirname(current_path)

        movie = FFMPEG::Movie.new(current_path)
        screenshot_path = directory + '/' + SecureRandom.hex + '.png'
        movie.screenshot(screenshot_path, options, other_options)

        FileUtils.rm(current_path)
        FileUtils.mv(screenshot_path, current_path)
      end
    end
  end
end
