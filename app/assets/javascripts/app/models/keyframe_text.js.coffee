class App.Models.KeyframeText extends Backbone.Model
  paramRoot: 'text'

  url: ->
    "/keyframes/#{App.currentKeyframe().get('id')}/texts/#{App.selectedKeyframeText().get('id')}/.json"

class App.Collections.KeyframeTextsCollection extends Backbone.Collection
  model: App.Models.KeyframeText

  url: ->
    "/keyframes/#{App.currentKeyframe().get('id')}/texts.json"
