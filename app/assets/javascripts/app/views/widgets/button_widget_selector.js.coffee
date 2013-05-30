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
      el: @$('.base-image-selector')
    @baseImageSelector.on 'select', (image) => @baseImage = image
    @baseImageSelector.render()

    @tappedImageSelector = new App.Views.ImageSelector
      collection: @collection
      image: @tappedImage
      el: @$('.tapped-image-selector')
    @tappedImageSelector.on 'select', (image) => @tappedImage = image
    @tappedImageSelector.render()

    @delegateEvents()

    @


  useSelectedImages: ->
    @trigger 'selected',
      baseImage:   @baseImage
      tappedImage: @tappedImage
