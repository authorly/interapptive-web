#= require ./sprite_widget

class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options) ->
    super

    @model.on 'change:image_id', @refresh, @
    @model.on 'change:disabled', @_disabledChanged, @

    view = new App.Views.ButtonWidgetImagesSelector
      widget:     @model
      collection: @model.collection.storybook.images
    view.on 'selected', @imagesSelected
    @selector = new App.Views.Modal(view: view)


  doubleClick: =>
    @selector.show()


  imagesSelected: (values) =>
    @model.set
      image_id:          values.baseImage?.id
      selected_image_id: values.tappedImage?.id

    @selector.hide()


  refresh: ->
    @_getImage()


  _disabledChanged: (__, disabled) ->
    @setOpacity(if disabled then 0 else 255)
