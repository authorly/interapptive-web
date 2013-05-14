##
# A view that allows to selecting an `Image` from an `ImagesCollection`.
# It displays the images in a table. It allows sorting and searching through the
# collection of images.
#

class App.Views.SpriteIndex extends Backbone.View
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
    @$el.html @template(options: @options)
    @delegateEvents() # patch for re-delegating events when the view is lost

    @collection.each @appendImage

    if @collection.length > 0
      @allowSortingSearching()
    else
      @$('.table').hide()
      @$('.modal-body').text @NO_IMAGES_MSG

    @


  appendImage: (image) =>
    view = new App.Views.Sprite(model: image)
    @$('tbody.files').append(view.render().el)


  setActiveImage: (event) ->
    @$(event.currentTarget).addClass('selected').siblings().removeClass 'selected'
    @$('.use-image').removeClass('disabled')

    @image = @collection.get @$(event.currentTarget).data('id')


  selectImage: ->
    @trigger 'select', @image


  allowSortingSearching: ->


  restoreMetaData: ->
    @$('.use-image').addClass('disabled')
    $children = $('tbody.files tr').addClass('image-row').removeClass('selected')
    $children.each (idx, tr) =>
      $tr = $(tr)
      $tr.attr('data-id', $tr.find('td').first().data('id'))
