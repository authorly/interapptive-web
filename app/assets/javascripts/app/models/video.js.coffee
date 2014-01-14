class App.Models.Video extends Backbone.Model

  toString: ->
    @get('name')


  widgetName: ->
    'video hotspot'

class App.Collections.VideosCollection extends App.Lib.TranscodeableCollection
  model: App.Models.Video
  _POLL_TIMER: null

  baseUrl: ->
    @storybook.baseUrl() + "/videos"


  url: ->
    @baseUrl() + '.json'


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
