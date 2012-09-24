class App.Views.Sprite extends Backbone.View
  template: JST["app/templates/assets/sprites/sprite"]
  tagName: 'tr'
  className: 'template-download fade'

  render: ->
    $(@el).html(@template(sprite: @model))
    this
