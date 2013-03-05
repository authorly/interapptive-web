#= require ../images/index
##
# A view that allows to selecting an `Image` from an `ImagesCollection`.
# It displays the images in a table. It allows sorting and searching through the
# collection of images.
#

class App.Views.SpriteIndex extends App.Views.ImageIndex
  template: JST['app/templates/assets/sprites/index']

  events:
    'click .image-row' : 'setActiveImage'
    'click .use-image' : 'selectImage'

  @NO_IMAGES_MSG = 'You dont have any Images. Please upload some by clicking on \'Images\' icon in the toolbar.'


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
      @$('.modal-body').text @NO_IMAGES_MSG

    @


  appendImage: (image) =>
    view = new App.Views.Sprite(model: image)
    @$('tbody.files').append(view.render().el)


  selectImage: ->
    @trigger 'select', @image


  allowSortingSearching: ->
    #
    # RFCTR:
    #     advancedtable is stupid plugin. It removes classes
    #     and ids from $(tbody.files > tr). We are using restoreMetaData
    #     function to restore all the information. Use something like
    #     http://www.datatables.net/
    #                                   WA
    #
    @$('.table-striped').advancedtable
      searchCaseSensitive : false
      afterRedrawThis     : @
      afterRedraw         : @restoreMetaData
      searchField         : '#search'
      loadElement         : '#loader'
      ascImage            : '/assets/advancedtable/up.png'
      descImage           : '/assets/advancedtable/down.png'


  restoreMetaData: ->
    @$('.use-image').addClass('disabled')
    $children = $('tbody.files tr').addClass('image-row').removeClass('selected')
    $children.each (idx, tr) =>
      $tr = $(tr)
      $tr.attr('data-id', $tr.find('td').first().data('id'))
