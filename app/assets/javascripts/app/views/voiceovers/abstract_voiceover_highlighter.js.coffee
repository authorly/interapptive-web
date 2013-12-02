# This view holds the common functionalities of voiceover highlighter
# views.
# It manages the elements and the method used to create highlights.
# It produces an array of time intervals.
class App.Views.AbstractVoiceoverHighlighter extends Backbone.View

  initialize: ->
    @keyframe = @model
    @playbackRate = 1
    @footnoteEventIds = []


  collectTimeIntervals: ->
    intervals = _.map @$('.word'), (el) -> @$(el).data('start')
    return [] if _.any(intervals, (interval) -> !interval or interval is "undefined" or interval is "null")
    intervals


  findExistingHighlightTimes: ->
    # Caching intervals here relies on the fact that when user 'Accepts' the highlights,
    # the highlight view along with modal is removed. This causes removal of child
    # highlighter view and hence garbage collection of @intervals. Next time, it'd be
    # fresh.
    @intervals ||= @keyframe.get('content_highlight_times')
    @trigger('enable:voiceoverPreview')
    return unless @intervals?.length > 0

    $words = @$('.word')
    $.each $words, @_wordProcessor

    @trigger('enable:acceptVoiceoverAlignment')


  setHighlightTimesForWordEls: ->
    $words = @$('.word')
    $words.removeClass('highlighted')

    for eventId in @footnoteEventIds
      @player.removeTrackEvent eventId

    @footnoteEventIds = []

    $.each $words, (index, word) =>
      @$(word).attr("id", "word-#{index}")
      startTime = Number(@$(word).attr('data-start'))
      if startTime
        if @$($words[index + 1]).length > 0
          endTime = Number(@$($words[index + 1]).attr('data-start'))
        else
          endTime = startTime + 1

        @player.footnote
          start:      startTime
          end:        endTime
          text:       ''
          target:     "word-#{index}"
          effect:     'applyclass'
          applyclass: 'highlighted'

        @footnoteEventIds.push @player.getLastTrackEventId()


  stopAlignment: =>
    @player.pause(@player.duration())
    @trigger('enable:voiceoverPreview')
    @removeWordHighlights()


  removeWordHighlights: =>
    @$('span.word.highlighted').removeClass('highlighted')


  resetHighlightControls: ->
    @$('.word.highlighted').removeClass('highlighted')


  enableBeginAlignment: ->
    #noop

  disableBeginAlignment: ->
    #noop