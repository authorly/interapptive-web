class App.Views.ButtonWidgetImagesSelector extends Backbone.View
  template: JST["app/templates/widgets/button_selector"]

  events:
    'click .use-images': 'useSelectedImages'

  initialize: (options={}) ->
    super

    @widget = options.widget

    @baseImage   = @widget.image()
    @tappedImage = @widget.selectedImage()

    @formattedWidgetName = App.Lib.StringHelper.decapitalize(@widget.displayName())
    App.trackUserAction "Opened #{@formattedWidgetName} image selector"


  render: ->
    @$el.html(@template(widget: @widget))

    @baseImageSelector = new App.Views.ImageSelector
      collection: @collection
      image: @baseImage
      defaultImage: @widget.defaultImage()
      el: @$('.base-image-selector')
      selectedImageViewClass: 'SelectedSprite'
    @listenTo @baseImageSelector, 'select', (image) => @baseImage = image
    @baseImageSelector.render()

    @tappedImageSelector = new App.Views.ImageSelector
      collection: @collection
      image: @tappedImage
      defaultImage: @widget.defaultSelectedImage()
      el: @$('.tapped-image-selector')
      selectedImageViewClass: 'SelectedSprite'
    @listenTo @tappedImageSelector, 'select', (image) => @tappedImage = image
    @tappedImageSelector.render()

    @


  remove: ->
    @stopListening @baseImageSelector
    @baseImageSelector.remove()

    @stopListening @tappedImageSelector
    @tappedImageSelector.remove()

    super


  useSelectedImages: =>
    @widget.set
      image_id:          @baseImage?.id
      selected_image_id: @tappedImage?.id

    App.vent.trigger('hide:modal')
    App.trackUserAction "Saved #{@formattedWidgetName} button"
