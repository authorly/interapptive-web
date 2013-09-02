class App.Views.ButtonWidgetImagesSelector extends Backbone.View
  template: JST["app/templates/widgets/button_selector"]

  events:
    'click .use-images': 'useSelectedImages'

  initialize: (options={}) ->
    super

    @widget = options.widget

    @baseImage   = @widget.image()
    @tappedImage = @widget.selectedImage()


  render: ->
    @$el.html(@template(widget: @widget))

    @baseImageSelector = new App.Views.ImageSelector
      collection: @collection
      image: @baseImage
      defaultImage: @widget.defaultImage()
      el: @$('.base-image-selector')
    @listenTo @baseImageSelector, 'select', (image) => @baseImage = image
    @baseImageSelector.render()

    @tappedImageSelector = new App.Views.ImageSelector
      collection: @collection
      image: @tappedImage
      defaultImage: @widget.defaultSelectedImage()
      el: @$('.tapped-image-selector')
    @listenTo @tappedImageSelector, 'select', (image) => @tappedImage = image
    @tappedImageSelector.render()

    @


  remove: ->
    @stopListening @baseImageSelector
    @baseImageSelector.remove()

    @stopListening @tappedImageSelector
    @tappedImageSelector.remove()

    super


  useSelectedImages: ->
    attributes =
      image_id:          @baseImage?.id
      selected_image_id: @tappedImage?.id
    unless attributes.image_id?
      attributes.scale = 1
    @widget.set attributes

    App.vent.trigger('hide:modal')
