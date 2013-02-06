class App.Views.Sprite extends Backbone.View

  template: JST["app/templates/assets/sprites/sprite"]

  tagName: 'tr'

  className: 'image-row'

  render: ->
    @$el.html(@template(sprite: @model)).attr('data-id', @model.id)
    @
