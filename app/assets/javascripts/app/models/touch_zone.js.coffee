class App.Models.TouchZone extends Backbone.Model
  schema:
    # scene_id:
    # origin_x:
    # origin_y:
    # radius:
    #video_id:
    # type: 'Select'
    # options: new App.Collections.VideosCollection()
    # sound_id:
    # type: 'Select'
    # options: new App.Collections.SoundsCollection()
    action_id:
      type: 'Select'
      options: new App.Collections.ActionsCollection()
      title: "Action"

  url: ->
    base = '/touch_zones/' + App.currentKeyframe().get('id') + '/'
    if @isNew() then (base + 'touch_zones.json') else (base + 'touch_zones/' + @id + '.json')

class App.Collections.TouchZonesCollection extends Backbone.Collection
  model: App.Models.TouchZone
  paramRoot: 'touchzone'

  initialize: (models, options) ->
    if options
      this.keyframe_id = options.keyframe_id

  url: ->
    '/touch_zones/' + this.keyframe_id + '/touch_zones.json'

  comparator: (touchzone) ->
    touchzone.get 'updated_at'
