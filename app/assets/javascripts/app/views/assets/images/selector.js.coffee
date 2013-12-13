##
# A view that allows to selecting an image from a collection.
# It also displays the current image, and updates it.
# If the selected image is removed, it is replaced by a default one (if available).
#
class App.Views.ImageSelector extends Backbone.View
  template: JST['app/templates/assets/images/selector']

  events:
    'click .images tbody tr' : 'imageSelected'

  # @NO_IMAGES_MSG = 'You dont have any Images. Please upload some by clicking on \'Images\' icon in the toolbar.'
      # @$('.modal-body').text @NO_IMAGES_MSG

  render: ->
    @$el.html @template()

    @imagesView = new App.Views.AssetIndex
      collection: @collection
      default: @options.defaultImage
      assetType: 'image'
      el: @$('.images')
    @imagesView.render()


    @selectedImageView = new App.Views[@options.selectedImageViewClass]
      image: @options.image
      el: @$('.selected-image')
    @listenTo @selectedImageView, 'select', @setImage
    @selectedImageView.render()


  remove: ->
    @imagesView.remove()
    @selectedImageView.remove()
    super


  imageSelected: (event) ->
    row = @$(event.currentTarget)
    row.addClass('selected').siblings().removeClass 'selected'

    image = @collection.get(@imagesView.getId(row)) || @options.defaultImage
    @setImage(image)


  setImage: (image) ->
    @selectedImageView.setImage image
    @trigger 'select', image
