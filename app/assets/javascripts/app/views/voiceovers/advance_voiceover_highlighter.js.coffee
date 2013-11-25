#= require ./abstract_voiceover_highlighter

# This view enables users to specify highlight times of every word separately.
# They can specify start time of each word in an associated input.

class App.Views.AdvanceVoiceoverHighlighter extends App.Views.AbstractVoiceoverHighlighter
  template: JST['app/templates/voiceovers/advance_voiceover_highlighter']

  events:
    'blur input.input-mini':     'changeHighlightTime'
    'keypress input.input-mini': 'keyPressed'


  initializeWordHighlights: ->
    intervals = @voiceover.get('times')

    $.each $('.word'), (index, word) =>
      @$(word).data('start', "#{intervals[index]}").
        find('input').val(intervals[index] || '')


  changeHighlightTime: (event) ->
    intervals     = @voiceover.get('times')
    time          = parseFloat(@$(event.currentTarget).val())
    $current_word = @$(event.currentTarget).parent()
    $words        = $current_word.parent().parent().find('span.word')

    current_index = $words.index($current_word)
    previous_time = parseFloat(intervals[current_index - 1])
    next_time     = parseFloat(intervals[current_index + 1])

    okay = true
    okay = okay && (time > previous_time) if previous_time
    okay = okay && (time < next_time)     if next_time

    if okay
      $current_word.data('start', time)
      intervals[current_index] = time
      @voiceover.set('times', intervals)

    else
      $current_word.find('input').val($current_word.data('start'))
      App.vent.trigger('show:message', 'warning', 'Time should be greater than previous word and less than next word.')


  keyPressed: (event) ->
    code = event.charCode
    isNumber = App.Lib.CharCodes[0] <= code <= App.Lib.CharCodes[9]
    isBackspace = code == App.Lib.KeyCodes.backspace
    isPeriod    = code == App.Lib.KeyCodes.period
    ok = not code or isNumber or isBackspace or isPeriod

    event.preventDefault() unless ok
