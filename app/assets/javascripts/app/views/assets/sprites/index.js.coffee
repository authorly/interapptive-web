#= require ../images/index

class App.Views.SpriteIndex extends App.Views.ImageIndex

  template: JST["app/templates/assets/sprites/index"]

  events:
    "click .thumbnail":               "setActiveImage"
    "touchstart, touchend .zoomable": "doZoom"
    "click .use-image":               "selectImage"

  selectImage: ->
    @trigger('image_select', @image)

