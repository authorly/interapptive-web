class App.Views.Scene extends Backbone.View
  template: JST["app/templates/scenes/scene"]
  tagName: 'li'

  render: ->
    $(@el).html(@template(scene: @model))
    this
