module Interapptive
  module ZencodedAsset
    extend ActiveSupport::Concern

    # To load transcoded Zencoder versions, run
    #
    # `bundle exec zencoder_fetcher --loop --interval 10 --url 'http://127.0.0.1:3000/zencoder' <ZENCODER_API_KEY>`
    #
    def duration
      ((meta_info[:response].try(:[], 'input').
        try(:[], 'duration_in_ms') || 0) / 1000.0).ceil
    end

    def transcode_complete?
      meta_info[:response].try(:[], 'job').
        try(:[], 'state') == 'finished'
    end

    def store_transcoding_result(response)
      self.meta_info[:response] = response
      save
    end

    def max_size
      if transcode_complete?
        meta_info[:response]['outputs'].map{|o| o['file_size_in_bytes']}.max
      else
        0
      end
    end
  end
end
