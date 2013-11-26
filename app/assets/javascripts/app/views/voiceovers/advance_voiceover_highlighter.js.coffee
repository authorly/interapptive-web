#= require ./abstract_voiceover_highlighter

class App.Views.AdvanceVoiceoverHighlighter extends App.Views.AbstractVoiceoverHighlighter
  template: JST['app/templates/voiceovers/advance_voiceover_highlighter']

  events:
    'blur input.input-mini': 'changeHighlightTime'

  DEFAULT_PLAYBACK_RATE: 1

  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @


  _wordProcessor: (index, word) =>
    @$(word).attr("data-start", "#{@intervals[index]}")
    @$(word).find('input').val(@intervals[index])


  changeHighlightTime: (event) ->
    time          = parseFloat(@$(event.currentTarget).val())
    $current_word = @$(event.currentTarget).parent()
    $words        = $current_word.parent().parent().find('span.word')

    current_index = $words.index($current_word)
    previous_time = parseFloat(@$($words[current_index - 1])?.attr('data-start'))
    next_time     = parseFloat(@$($words[current_index + 1])?.attr('data-start'))

    okay = true
    okay = okay && (time > previous_time) if previous_time
    okay = okay && (time < next_time)     if next_time

    if okay
      $current_word.attr('data-start', time)

    else
      $current_word.find('input').val($current_word.attr('data-start'))
      App.vent.trigger('show:message', 'warning', 'Time should be greater than previous word and less than next word.')
