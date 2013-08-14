class App.Models.Video extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.VideosCollection extends Backbone.Collection
  model: App.Models.Video
  _POLL_TIMER: null

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  baseUrl: ->
    @storybook.baseUrl() + "/videos"


  url: ->
    @baseUrl() + '.json'


  pollUntilTranscoded: ->
    @_POLL_TIMER ||= window.setTimeout @_poll, 5000


  _poll: =>
    ids = _.pluck @unTranscoded(), 'id'
    if ids.length == 0
      @_POLL_TIMER = null
    else
      @fetch
        remove: false
        data:
          # passing here the 'ids' key breaks.. both `fetch` and `$.ajax` :|
          # @dira 2013-08-13
          video_ids: ids
        success: @_repoll
        error: @_repoll


  _repoll: =>
    @_POLL_TIMER = null
    @pollUntilTranscoded()


  unTranscoded: ->
    @where(transcode_complete: false)
