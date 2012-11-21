module Interapptive
  module CarrierWave
    module FontReader
      extend ActiveSupport::Concern

      module ClassMethods
        def extract_meta_info(*args)
          process :extract_meta_info => []
        end
      end

      def extract_meta_info(*args)
        font_file = TTFunk::File.open(current_path)

        # HACK to find out the ASCII name
        font_name = font_file.name.font_name.detect do |f|
          n = f.unpack('C*')[0]
          (n >= 65 && n <= 90) || (n >= 97 && n <= 122)
        end

        raise ::CarrierWave::ProcessingError.new("Failed to read valid font name from the font file #{current_path}") unless font_name
        @model.meta_info[:font_name] = font_name.to_s
      end
    end
  end
end
