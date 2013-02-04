#= require ./sprite_widget

class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options) ->
    super

    view = new App.Views.ButtonWidgetImagesSelector
      collection: App.imagesCollection
      widget:     options.model
    view.on 'selected', @imagesSelected
    @selector = new App.Views.Modal(view: view)


  doubleClick: =>
    @selector.show()


  imagesSelected: (values) =>
    if @_url != values.baseUrl
      @_url = values.baseUrl
      @trigger('change', 'url')
      # TODO integrate better with the new sprites
      @sprite.url = @_url
      @_getImage()

    if @_selectedUrl != values.tappedUrl
      @_selectedUrl = values.tappedUrl
      @trigger('change', 'selectedUrl')


    @selector.hide()
