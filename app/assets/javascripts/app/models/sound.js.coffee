class App.Models.Sound extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.SoundsCollection extends App.Lib.TranscodeableCollection
  model: App.Models.Sound
  _POLL_TIMER: null

  baseUrl: ->
    @storybook.baseUrl() + "/sounds"


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
          sound_ids: ids
        success: @_repoll
        error: @_repoll
