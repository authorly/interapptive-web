class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'
  
  url: ->
    '/scenes/' + this.get('scene_id') + '/keyframes'

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  initialize: (models, options) ->
    this.scene = options.scene

  url: ->
    '/scenes/' + this.scene.get('id') + '/keyframes.json'
