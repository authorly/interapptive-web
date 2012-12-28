#= require ../images/index
##
# A view that allows to selecting an `Image` from an `ImagesCollection`.
# It displays the images in a table. It allows sorting and searching through the
# collection of images.
#
class App.Views.SpriteIndex extends App.Views.ImageIndex
  template: JST["app/templates/assets/sprites/index"]

  events:
    'click                .image-row' : 'setActiveImage'
    'click                .use-image' : 'selectImage'
    'touchstart, touchend .zoomable'  : 'doZoom'


  initialize: ->
    super
    @collection.on 'reset', @render
    @collection.fetch()


  render: =>
    super

    if @collection.length > 0
      @allowSortingSearching()
    else
      @$('.table').hide()
      @$('.modal-body').text("You dont have any Images. Please upload some by clicking on 'Images' icon in the toolbar.")

    @


  appendImage: (image) =>
    view = new App.Views.Sprite(model: image)
    @$('tbody.files').append(view.render().el)


  allowSortingSearching: ->
    # TODO: WA: advancedtable is stupid plugin. It removes classes
    # and ids from $(tbody.files > tr). We are using restoreMetaData
    # function to restore all the information. Use something like
    # http://www.datatables.net/
    @$(".table-striped").advancedtable({
      searchField: "#search",
      loadElement: "#loader",
      searchCaseSensitive: false,
      ascImage: "/assets/advancedtable/up.png",
      descImage: "/assets/advancedtable/down.png",
      afterRedraw: @restoreMetaData,
      afterRedrawThis: @,
    })


  restoreMetaData: ->
    @$el.find('.use-image').addClass('disabled')
    $children = $('tbody.files tr').addClass('image-row').removeClass('selected')
    $children.each (idx, tr) =>
      $tr = $(tr)
      $tr.attr('data-id', $tr.find('td').first().data('id'))
