##
# A view that allows to selecting an image from a collection.
#
class App.Views.ImageSelector extends App.Views.AssetIndex

  events:
    'click tbody tr' : 'setActiveImage'

  # @NO_IMAGES_MSG = 'You dont have any Images. Please upload some by clicking on \'Images\' icon in the toolbar.'
      # @$('.modal-body').text @NO_IMAGES_MSG


  initialize: (options) ->
    options.assetType = 'image'
    super(options)


  setActiveImage: (event) ->
    row = @$(event.currentTarget)
    row.addClass('selected').siblings().removeClass 'selected'

    @image = @collection.get(@getId(row))
    @trigger 'select', @image
