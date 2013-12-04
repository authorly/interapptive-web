# This view holds the common functionalities of voiceover highlighter
# views.
# It manages the elements and the method used to create highlights.
# It produces an array of time intervals.
class App.Views.AbstractVoiceoverHighlighter extends Backbone.View

  initialize: ->
    super
    @keyframe = @model
    @player = @options.player
    @footnoteEventIds = []
    @playbackRate = 1
    @intervals ||= @keyframe.get('content_highlight_times')



  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @initializeWordHighlights()
    @


  collectTimeIntervals: ->
    intervals = _.map @$('.word'), (el) -> Number(@$(el).data('start'))
    faulty = _.any intervals, (interval) ->
      !interval or interval is "undefined" or interval is "null"
    if faulty then [] else intervals



  preparePreview: ->
    @removeFootnotes()
    @removeWordHighlights()

    $words = @$('.word')
    $.each $words, (index, word) =>
      id = "word-#{index}"
      @$(word).attr('id', id)
      startTime = Number(@$(word).data('start'))
      if startTime
        if @$($words[index + 1]).length > 0
          endTime = Number(@$($words[index + 1]).data('start'))
        else
          endTime = startTime + 1

        @player.footnote
          start:      startTime
          end:        endTime
          text:       ''
          target:     id
          effect:     'applyclass'
          applyclass: 'highlighted'

        @footnoteEventIds.push @player.getLastTrackEventId()

    @disableHighlightControls()


  cleanupPreview: ->
    @removeFootnotes()
    @removeWordHighlights()
    @enableHighlightControls()


  removeFootnotes: ->
    for eventId in @footnoteEventIds
      @player.removeTrackEvent eventId

    @footnoteEventIds = []


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
