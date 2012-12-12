class App.Views.ButtonWidgetImagesSelector extends Backbone.View
  template: JST["app/templates/widgets/button_selector"]

  events:
    'click .use-images': 'useSelectedImages'

  initialize: (options={}) ->
    super

    @widget = options.widget

    @baseImageUrl = @widget._url
    @tappedImageUrl = @widget._selectedUrl


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
    newUrl = image.get('url')
    if newUrl != @baseImageUrl
      @baseImageUrl = image.get('url')
      @baseImageView.setUrl @baseImageUrl


  tappedImageChosen: (image) =>
    newUrl = image.get('url')
    if newUrl != @tappedImageUrl
      @tappedImageUrl = image.get('url')
      @tappedImageView.setUrl @tappedImageUrl


  useSelectedImages: ->
    @trigger 'selected', baseUrl: @baseImageUrl, tappedUrl: @tappedImageUrl


  _ensureSubviewsCreated: ->
    unless @baseImageView?
      @baseImageView = new App.Views.SelectedImage(url: @baseImageUrl)
      @baseImageChooser = new App.Views.SpriteIndex
        collection: @collection
        select: 'Select'
      @baseImageChooser.on 'select', @baseImageChosen

    unless @tappedImageView?
      @tappedImageView = new App.Views.SelectedImage(url: @tappedImageUrl)
      @tappedImageChooser = new App.Views.SpriteIndex
        collection: @collection
        select: 'Select'
      @tappedImageChooser.on 'select', @tappedImageChosen
