# This view holds the common functionalities of voiceover highlighter
# views.
# It manages the elements and the method used to create highlights.
# It produces an array of time intervals.
class App.Views.AbstractVoiceoverHighlighter extends Backbone.View

  initialize: ->
    super
    @voiceover = @model
    @player = @options.player
    @playbackRate = 1


  render: ->
    @$el.html(@template(voiceover: @voiceover))
    @initializeWordHighlights()
    @


  preparePreview: ->
    @removeWordHighlights()

    footnoteEventIds = []
    $words = @$('.word')
    intervals = @voiceover.get('times')

    $.each $words, (index, word) =>
      id = "word-#{index}"
      @$(word).attr('id', id)
      startTime = Number(intervals[index])
      if startTime
        if @$($words[index + 1]).length > 0
          endTime = Number(intervals[index + 1])
        else
          endTime = startTime + 1

        @player.footnote
          start:      startTime
          end:        endTime
          text:       ''
          target:     id
          effect:     'applyclass'
          applyclass: 'highlighted'

        footnoteEventIds.push @player.getLastTrackEventId()

    @disableHighlightControls()

    # to be used by the manager of the player
    footnoteEventIds


  cleanupPreview: ->
    @removeWordHighlights()
    @enableHighlightControls()


  cacheHighlightTimes: ->
    intervals = @_collectTimeIntervals()
    @voiceover.setValid(!@_hasFaultyIntervals(intervals))
    @voiceover.set('times', intervals)


  # if the highlighter uses the player, this method is invoked
  # when playing is paused
  playEnded: ->
    # to be overridden if needed


  initializeWordHighlights: ->
    # to be overridden if needed


  removeWordHighlights: =>
    @$('.word.highlighted').removeClass('highlighted')


  disableHighlightControls: ->
    # to be overridden if needed


  enableHighlightControls: ->
    # to be overridden if needed


  _hasFaultyIntervals: (intervals) ->
    _.any intervals, (interval) ->
      !interval or interval is "undefined" or interval is "null"


  _collectTimeIntervals: ->
    _.map @$('.word'), (el) -> Number(@$(el).data('start'))
