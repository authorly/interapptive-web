module Interapptive
  module CarrierWave
    module SoundDuration
      extend ActiveSupport::Concern

      module ClassMethods
        def store_duration(*args)
          process :store_duration => args
        end
      end

      # Expects Sox version 14.4.0
      def store_duration(*args)
        IO.popen("sox #{current_path} -n stat 2>&1") do |output|
          length = output.readlines.detect{|line| line.start_with?('Length')}
          if length.present?
            model.meta_info[:duration] = length.match(/:\s*(.*)/)[1].to_f
          else
            model.meta_info[:duration] = 8000.00
          end
        end
      end
    end
  end
end

