#= require ./sprite_widget

class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options) ->
    super

    @model.on 'change:url', @refresh, @

    view = new App.Views.ButtonWidgetImagesSelector
      widget:     @model
      collection: @model.collection.scene.storybook.images
    view.on 'selected', @imagesSelected
    @selector = new App.Views.Modal(view: view)


  doubleClick: =>
    @selector.show()


  imagesSelected: (values) =>
    if values.baseUrl?
      @model.set url: values.baseUrl
    if values.tappedUrl?
      @model.set selected_url: values.tappedUrl

    @selector.hide()


  refresh: ->
    @_getImage()
