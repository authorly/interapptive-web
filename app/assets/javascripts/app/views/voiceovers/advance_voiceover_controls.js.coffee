#= require ./abstract_voiceover_controls

class App.Views.AdvanceVoiceoverControls extends App.Views.AbstractVoiceoverControls
  template: JST['app/templates/voiceovers/advance_voiceover_controls']
  DEFAULT_PLAYBACK_RATE: 1

  initialize: ->
    @keyframe = @model
    @playbackRate = @DEFAULT_PLAYBACK_RATE


  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @


  findExistingHighlightTimes: ->
    intervals = @keyframe.get('content_highlight_times')
    App.vent.trigger('enable:voiceoverPreview')
    return unless intervals?.length > 0

    $words = @$('.word')
    $.each $words, (index, word) =>
      @$(word).attr("data-start", "#{intervals[index]}")
      @$(word).find('input').val(intervals[index])

    App.vent.trigger('enable:acceptVoiceoverAlignment')

  setHighlightTimesForWordEls: ->


  stopAlignment: =>
    @player.pause(@player.duration())
    App.vent.trigger('enable:voiceoverPreview')
    @removeWordHighlights()


  removeWordHighlights: =>
    @$('span.word.highlighted').removeClass('highlighted')


  enableBeginAlignment: ->
    #noop

  disableBeginAlignment: ->
    #noop
