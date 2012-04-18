class App.Models.Keyframe extends Backbone.Model
  url: ->
    '/scenes/' + this.get('scene_id') + '/keyframes/' + this.get('id')

  toJSON: ->
    { keyframe: _.clone this.attributes }

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  initialize: (models, options) ->
    this.scene = options.scene

  url: ->
    '/scenes/' + this.scene.get('id') + '/keyframes.json'
