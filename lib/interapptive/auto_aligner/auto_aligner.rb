class AutoAligner
  if ['development', 'test'].include?(Rails.env)
    path_modifier = '..'
  else
    path_modifier = File.join('..', '..')
  end

  ALIGNER_DIRECTORY = File.join(Rails.root, path_modifier, 'long-audio-aligner')
  WORD_REGEX        = /(\w+)\(([^)]+),([^)]+)\)/

  def initialize(keyframe)
    @keyframe = keyframe
  end

  def logger
    Rails.logger
  end

  def align
    write_text_file
    download_audio_file
    heighlights = extract_highlights
    processed_times = process_heighlights(heighlights)
    @keyframe.content_highlight_times = processed_times
    @keyframe.save
  end

  def process_heighlights(heighlights)
    processed_heighlights = []
    original_words = @keyframe.text.join(' ').split(' ')

    index = 0
    original_words.each do |word|
      if heighlights[index][:word] == word.downcase.gsub(/\W/, '')
        processed_heighlights << heighlights[index][:time]
        index = index + 1

      else
        processed_heighlights << '0.0'
      end
    end

    processed_heighlights
  end

  def extract_highlights
    f = IO.popen("cd #{ALIGNER_DIRECTORY} && java -ms400m -mx1500m -jar bin/aligner.jar #{audio_filename} input.txt")
    # TODO: WA: Following blocks the worker process till log is
    # written. Fork it to child process.
    heighlights_string = f.readlines[4].gsub("\n", '')
    logger.info heighlights_string
    f.close
    extract_times(heighlights_string)
  end

  def extract_times(heighlights_string)
    times = []
    heighlights_string.split(' ').each do |word|
      m = word.match(WORD_REGEX)
      times << { :word => m[1], :time => m[2] }
    end
    times
  end

  def write_text_file
    File.open(File.join(ALIGNER_DIRECTORY, 'input.txt'), 'w') do |f|
      f.write(@keyframe.text.join(' '))
    end
  end

  def audio_filename
    @audio_filename ||= File.basename(audio_url)
  end

  def audio_url
    @audio_url ||= @keyframe.voiceover.sound.aligner_wav.url
  end

  def download_audio_file
    File.open(File.join(ALIGNER_DIRECTORY, audio_filename), 'wb+') do |audio|
      open(audio_url, 'rb') do |read_file|
        audio << read_file.read
      end
    end
  end
end
