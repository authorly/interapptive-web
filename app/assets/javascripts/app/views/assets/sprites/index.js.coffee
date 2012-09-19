#= require ../images/index

class App.Views.SpriteIndex extends App.Views.ImageIndex

  template: JST["app/templates/assets/sprites/index"]

  events:
    "click .thumbnail":               "setActiveImage"
    "touchstart, touchend .zoomable": "doZoom"
    "click .use-image":               "selectImage"

  selectImage: ->
    @trigger('image_select', @image)

  fetchImages: ->
    $.getJSON "/storybooks/#{App.currentStorybook().get('id')}/images", (files) ->
      fillTable(files)
      allowSortingSearching()

  fillTable:(files) ->

  allowSortingSearching: ->
    $("#loading").remove()
    $("#searchtable").show()
    $(".table-striped").advancedtable({searchField: "#search", loadElement: "#loader", searchCaseSensitive: false, ascImage: "/assets/advancedtable/up.png", descImage: "/assets/advancedtable/down.png"})

