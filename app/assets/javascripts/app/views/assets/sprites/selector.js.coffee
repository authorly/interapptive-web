##
# A view that allows to selecting an image from a collection.
# It also displays the current image, and updates it.
#
class App.Views.ImageSelector extends Backbone.View
  template: JST['app/templates/assets/images/selector']

  events:
    'click .images tbody tr' : 'setActiveImage'

  # @NO_IMAGES_MSG = 'You dont have any Images. Please upload some by clicking on \'Images\' icon in the toolbar.'
      # @$('.modal-body').text @NO_IMAGES_MSG

  render: ->
    @$el.html @template()

    @imagesView = new App.Views.AssetIndex
      collection: @collection
      assetType: 'image'
      el: @$('.images')
    @imagesView.render()


    @selectedImageView = new App.Views.SelectedImage
      image: @options.image
      el: @$('.selected-image')
    @selectedImageView.render()


  setActiveImage: (event) ->
    row = @$(event.currentTarget)
    row.addClass('selected').siblings().removeClass 'selected'

    @image = @collection.get(@imagesView.getId(row))

    @selectedImageView.setImage @image

    @trigger 'select', @image
