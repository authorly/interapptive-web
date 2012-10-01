#= require ../images/index

class App.Views.SpriteIndex extends App.Views.ImageIndex
  template: JST["app/templates/assets/sprites/index"]

  events:
    "click .image-row":               "setActiveImage"
    "touchstart, touchend .zoomable": "doZoom"
    "click .use-image":               "selectImage"

  selectImage: ->
    @trigger('image_select', @image)

  fetchImages: ->
    @fillTable()

  fillTable: ->
    @collection.fetch
     success: (images, response) =>
       images.each (image) => @appendImage(image)
       @allowSortingSearching()

  appendImage: (image) ->
    view = new App.Views.Sprite(model: image)
    $('tbody.files').append(view.render().el)

  allowSortingSearching: ->
    $("#searchtable").show()
    $(".table-striped").advancedtable({searchField: "#search", loadElement: "#loader", searchCaseSensitive: false, ascImage: "/assets/advancedtable/up.png", descImage: "/assets/advancedtable/down.png"})
