# Provides means to access CMUSphinx aligner at
# https://github.com/waseem/long-audio-aligner in our Rails
# application.
class Aligner
  class UnprocessableFileError < StandardError; end

  attr_accessor :audio, :transcription

  PATH_TO_ALIGNER = Rails.application.config.long_audio_aligner_configuration[:aligner_path]

  # It is assumed that path of aligner.jar is PATH_TO_ALIGNER/bin/aligner.jar
  COMMAND = "cd #{PATH_TO_ALIGNER}; java -mx1500m -ms400m -jar " + PATH_TO_ALIGNER + 'bin/aligner.jar'

  # Matches all occurrences that resemble "for(1.0345,1.5476)" and form a
  # match group of "for", "1.0345"
  WORD_REGEX = /([a-z]+)\((\d+\.\d+),\d+\.\d+\)/

  # Create a new Aligner object with path to audio file in +audio+
  # and path to transcription file in +transcription+.
  #
  # For best results, always provide full paths for both +audio+
  # and +transcription+ files.
  def initialize(audio, transcription)
    @audio = audio
    @transcription = transcription
  end

  # Aligns a wav audio file with corresponding transcription text file
  # and returns result of transcription.
  #
  # a = Aligner.new('/home/waseem/Repositories/Projects/Interapptive/Documents/Aligner/resource/wav/dedication.wav',  '/home/waseem/Repositories/Projects/Interapptive/Documents/Aligner/resource/transcription/dedication.txt')
  # a.align
  # #=> "for(1.0176871,1.2072562) those(1.2072562,1.5863945) who(1.5863945,1.6662132) protect(1.6662132,2.1351473) wild(2.1351473,2.4943311) places(2.4943311,3.1528344) and(3.4222221,3.601814) to(3.601814,3.6916099) the(3.6916099,3.8013606) snowman(3.8013606,4.3900228) that(4.3900228,4.5496597) lives(4.5496597,4.898866) in(4.898866,5.038549) every(5.038549,5.317914) childs(5.317914,5.7170067) heart(5.7170067,6.026304)"
  # a.alignment
  # #=> "for(1.0176871,1.2072562) those(1.2072562,1.5863945) who(1.5863945,1.6662132) protect(1.6662132,2.1351473) wild(2.1351473,2.4943311) places(2.4943311,3.1528344) and(3.4222221,3.601814) to(3.601814,3.6916099) the(3.6916099,3.8013606) snowman(3.8013606,4.3900228) that(4.3900228,4.5496597) lives(4.5496597,4.898866) in(4.898866,5.038549) every(5.038549,5.317914) childs(5.317914,5.7170067) heart(5.7170067,6.026304)"
  def align
    # FIXME: WA: Rescue any exceptions
    begin
      f = IO.popen(COMMAND + ' ' + @audio + ' ' + @transcription)
    rescue => e
    end
    output = f.readlines
    if output.blank?
      raise UnprocessableFileError, "Can not align #{@audio} with transcription #{@transcription}"
    end

    @alignment = output.last.chomp
    f.close
    self
  end

  def alignment
    return @alignment if @alignment
    align
    @alignment
  end

  # Converts alignment into a Hash.
  def to_h
    to_a.inject([]) do |out, elm|
      out << { :word => elm[0], :start_at => elm[1] }
    end
  end

  def to_a
    align unless @alignment
    return [] if @alignment.match('<unk>')
    @alignment.scan(WORD_REGEX)
  end
end
