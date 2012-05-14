class App.Views.Keyframe extends Backbone.View
  template: JST["app/templates/keyframes/keyframe"]
  
  tagName: 'li'

  render: ->
    $(@el).html(@template(keyframe: @model))
    this
