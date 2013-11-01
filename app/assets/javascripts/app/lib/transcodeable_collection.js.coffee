# A Backbone collection that can hold models that could be transcoded.
# The primary use of this collection is to poll for completion of
# transcoding process. The inheriting class must:
#
# define an _POLL_TIMER initialized to null
# define an _poll function that is called on each end of polling event
class App.Lib.TranscodeableCollection extends Backbone.Collection

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  pollUntilTranscoded: ->
    @_POLL_TIMER ||= window.setTimeout @_poll, 5000

  _repoll: =>
    @_POLL_TIMER = null
    @pollUntilTranscoded()


  unTranscoded: ->
    @where(transcode_complete: false)


  hasOnlyTranscodedVideos: ->
    @unTranscoded().length == 0
