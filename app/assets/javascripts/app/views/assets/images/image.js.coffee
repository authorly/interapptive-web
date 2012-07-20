class App.Views.Image extends Backbone.View
  template: JST["app/templates/assets/images/image"]
  tagName: 'li'

  render: ->
    $(@el).html(@template(image: @model))
    $(@el).addClass "zoomable"
    this
