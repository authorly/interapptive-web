class App.Views.ButtonWidgetImagesSelector extends Backbone.View
  template: JST["app/templates/widgets/button_selector"]

  events:
    'click .use-images': 'useSelectedImages'

  # @param collection the Backbone collection of available images
  initialize: (options={}) ->
    super

    @widget = options.widget

    @baseImage = @collection.get(@widget.get('image_id'))
    @tappedImageId = @widget.get('selected_image_id')


  render: ->
    @_ensureSubviewsCreated()

    @$el.html(@template(widget: @widget))

    @$('.baseImage').html   @baseImageView.  render().el
    @$('.tappedImage').html @tappedImageView.render().el

    @$('.baseImageChooser').html   @baseImageChooser.  render().el
    @$('.tappedImageChooser').html @tappedImageChooser.render().el

    @delegateEvents() # patch for re-delegating events when the view is lost
    @collection.fetch()

    @


  baseImageChosen: (image) =>
    if image != @baseImage
      @baseImage = image
      @baseImageView.setImage image


  tappedImageChosen: (image) =>
    if image != @tappedImage
      @tappedImage = image
      @tappedImageView.setImage image


  useSelectedImages: ->
    @trigger 'selected', baseImage: @baseImage, tappedImage: @tappedImage


  _ensureSubviewsCreated: ->
    unless @baseImageView?
      @baseImageView = new App.Views.SelectedImage(@baseImage)
      @baseImageChooser = new App.Views.SpriteIndex
        collection: @collection
        select: 'Select'
      @baseImageChooser.on 'select', @baseImageChosen

    unless @tappedImageView?
      @tappedImageView = new App.Views.SelectedImage(@tappedImage)
      @tappedImageChooser = new App.Views.SpriteIndex
        collection: @collection
        select: 'Select'
      @tappedImageChooser.on 'select', @tappedImageChosen
