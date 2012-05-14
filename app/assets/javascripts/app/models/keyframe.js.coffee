class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'
  
  url: ->
    '/scenes/' + App.currentScene().get('id') + '/keyframes'

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  initialize: (models, options) ->
    if options
      this.scene_id = options.scene_id

  url: ->
    '/scenes/' + this.scene_id + '/keyframes.json'
