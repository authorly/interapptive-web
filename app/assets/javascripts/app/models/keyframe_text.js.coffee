class App.Models.KeyframeText extends Backbone.Model
  paramRoot: 'text'

  url: ->
    return "/keyframes/#{App.currentKeyframe().get('id')}/texts.json" if @isNew()
    "/keyframes/#{App.currentKeyframe().get('id')}/texts/#{App.currentKeyframeText().get('id')}.json"
    

class App.Collections.KeyframeTextsCollection extends Backbone.Collection
  model: App.Models.KeyframeText

  url: ->
    "/keyframes/#{App.currentKeyframe().get('id')}/texts.json"
