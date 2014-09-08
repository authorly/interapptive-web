require 'ruby-sox'

module Interapptive
  module CarrierWave
    module WavVideoConverter
      extend ActiveSupport::Concern

      module ClassMethods
        def encode_to_wav(*args)
          process :encode_to_wav => []
        end
      end

      def encode_to_wav(*args)
        cache_stored_file! if !cached?
        directory = File.dirname(current_path)

        output_file_name = File.join(directory, File.basename(current_path, File.extname(current_path))) + '.wav'

        Sox::Cmd.new.add_input(current_path).
          set_output(output_file_name, :bits => 16).
          set_effects(:channels => 1, :rate => 16000).
          run

        File.rename(output_file_name, current_path)
      end

      private

      def prepare!
        cache_stored_file! if !cached?
      end
    end
  end
end
