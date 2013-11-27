class App.Views.AbstractVoiceoverControls extends Backbone.View

  initialize: ->
    @keyframe = @model
    @playbackRate = 1


  collectTimeIntervals: ->
    intervals = _.map @$('.word'), (el) -> @$(el).data('start')
    return intervals if _.every(intervals, (interval) -> interval? && interval != "undefined" && interval != "null")
    []


  findExistingHighlightTimes: ->
    # Cachins intervals here relies on the fact that when user 'Accepts' the highlights,
    # the highlight view along with modal is removed. This causes removal of child
    # highlighter view and hence garbage collection of @intervals. Next time, it'd be
    # fresh.
    @intervals ||= @keyframe.get('content_highlight_times')
    App.vent.trigger('enable:voiceoverPreview')
    return unless @intervals?.length > 0

    $words = @$('.word')
    $.each $words, @_wordProcessor

    App.vent.trigger('enable:acceptVoiceoverAlignment')


  setHighlightTimesForWordEls: ->
    $words = @$('.word')
    $words.removeClass('highlighted')
    $.each $words, (index, word) =>
      @$(word).attr("id", "word-#{index}")
      startTime = @$(word).attr('data-start')
      if startTime
        if @$($words[index + 1]).length > 0
          endTime = parseFloat(@$($words[index + 1]).attr('data-start'))

        else
          endTime = parseFloat(startTime) + 1

        @player.footnote
          start:      startTime
          end:        endTime
          text:       ''
          target:     "word-#{index}"
          effect:     'applyclass'
          applyclass: 'highlighted'


  stopAlignment: =>
    @player.pause(@player.duration())
    App.vent.trigger('enable:voiceoverPreview')
    @removeWordHighlights()


  removeWordHighlights: =>
    @$('span.word.highlighted').removeClass('highlighted')


  resetHighlightControls: ->
    @$('.word.highlighted').removeClass('highlighted')


  enableBeginAlignment: ->
    #noop

  disableBeginAlignment: ->
    #noop
